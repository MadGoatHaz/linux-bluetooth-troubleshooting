#!/usr/bin/env python3
"""
Arch Wiki Automated Submission Script (Python Version)
This script orchestrates the entire process of submitting content to Arch Wiki
using the MediaWiki API with enhanced error handling, logging, and security features.
"""

import subprocess
import json
import time
import os
import sys
import argparse
from typing import Dict, List, Optional, Any

# Configuration
WIKI_API_URL = "https://wiki.archlinux.org/api.php"
COOKIES_FILE = "/tmp/archwiki_cookies.txt"
LOG_FILE = "archwiki_submission.log"

class ArchWikiBot:
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password
        self.log_file = LOG_FILE
        self.session = None
        
    def log_message(self, message: str) -> None:
        """Logs messages to a file with a timestamp."""
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S UTC")
        log_entry = f"[{timestamp}] {message}"
        with open(self.log_file, "a") as f:
            f.write(log_entry + "\n")
        print(f"Log: {message}")
        
    def run_curl_command(self, data_params: Dict[str, str], method: str = "POST", 
                        expect_json: bool = True, initial_cookies: bool = False) -> Any:
        """Helper function to execute curl commands and parse JSON responses."""
        cmd = ["curl", "-s", "-X", method, WIKI_API_URL]

        if initial_cookies:
            # For the very first login token request, we don't have cookies yet
            cmd.extend(["-c", COOKIES_FILE])
        else:
            # For subsequent requests, read and write cookies
            cmd.extend(["-b", COOKIES_FILE, "-c", COOKIES_FILE])

        # Add data parameters
        for key, value in data_params.items():
            if key in ["text", "summary"]:  # URL-encode specific parameters
                cmd.extend(["--data-urlencode", f"{key}={value}"])
            else:
                cmd.extend(["-d", f"{key}={value}"])
                
        # Add user agent
        cmd.extend(["--user-agent", "ArchWikiBot/1.0 (Linux Bluetooth Troubleshooting Project)"])
        
        # Add timeout options
        cmd.extend(["--connect-timeout", "30", "--max-time", "120"])

        self.log_message(f"Executing curl command: {' '.join(cmd)}")
        process = subprocess.run(cmd, capture_output=True, text=True, check=False)

        if process.returncode != 0:
            self.log_message(f"Curl command failed with exit code {process.returncode}: {process.stderr}")
            raise Exception(f"Curl command failed: {process.stderr}")

        if expect_json:
            try:
                return json.loads(process.stdout)
            except json.JSONDecodeError:
                self.log_message(f"Failed to decode JSON: {process.stdout}")
                raise Exception("Failed to decode JSON response from API.")
        return process.stdout

    def get_login_token(self) -> str:
        """Get login token from Arch Wiki API."""
        self.log_message("Attempting to get login token...")
        response = self.run_curl_command(
            {"action": "query", "meta": "tokens", "type": "login", "format": "json"}, 
            initial_cookies=True
        )
        token = response.get("query", {}).get("tokens", {}).get("logintoken")
        if not token:
            self.log_message(f"Failed to get login token: {response}")
            raise Exception("Could not retrieve login token.")
        self.log_message("Login token obtained.")
        return token

    def login(self, login_token: str) -> None:
        """Login to Arch Wiki API."""
        self.log_message(f"Attempting to log in as {self.username}...")
        response = self.run_curl_command({
            "action": "login",
            "lgname": self.username,
            "lgpassword": self.password,
            "lgtoken": login_token,
            "format": "json"
        })
        result = response.get("login", {}).get("result")
        if result != "Success":
            reason = response.get("login", {}).get("reason", "Unknown reason")
            self.log_message(f"Login failed: {reason}. Full response: {response}")
            raise Exception(f"Login failed: {reason}")
        self.log_message("Login successful.")

    def get_csrf_token(self) -> str:
        """Get CSRF token for editing."""
        self.log_message("Attempting to get CSRF token...")
        response = self.run_curl_command({
            "action": "query", 
            "meta": "tokens", 
            "type": "csrf", 
            "format": "json"
        })
        token = response.get("query", {}).get("tokens", {}).get("csrftoken")
        if not token:
            self.log_message(f"Failed to get CSRF token: {response}")
            raise Exception("Could not retrieve CSRF token.")
        self.log_message("CSRF token obtained.")
        return token

    def submit_wiki_page(self, title: str, content: str, summary: str, 
                        csrf_token: str, is_bot_edit: bool = True) -> None:
        """Submit page content to Arch Wiki."""
        self.log_message(f"Attempting to submit page: '{title}' with summary: '{summary}'...")
        params = {
            "action": "edit",
            "title": title,
            "text": content,
            "summary": summary,
            "token": csrf_token,
            "format": "json"
        }
        if is_bot_edit:
            params["bot"] = "1"

        response = self.run_curl_command(params)
        result = response.get("edit", {}).get("result")
        if result != "Success":
            error_code = response.get("error", {}).get("code", "N/A")
            error_info = response.get("error", {}).get("info", "Unknown error")
            self.log_message(f"Edit failed for '{title}': {error_code} - {error_info}. Full response: {response}")
            
            # Handle specific error cases
            if error_code == "badtoken":
                raise Exception("CSRF token is invalid. Please get a new CSRF token and try again.")
            elif error_code == "maxlag":
                raise Exception("Wiki is currently lagging. Please try again later.")
            elif error_code == "spamdetected":
                raise Exception("Content detected as spam. Please review your content.")
            elif error_code == "abusefilter":
                raise Exception("Content blocked by abuse filter. Please review your content.")
            else:
                raise Exception(f"Edit failed: {error_code} - {error_info}")
                
        self.log_message(f"Page '{title}' submitted successfully. New revision ID: {response.get('edit',{}).get('newrevid')}")

    def exponential_backoff(self, func, *args, max_retries: int = 5, **kwargs) -> Any:
        """Execute function with exponential backoff for transient errors."""
        retry_count = 0
        delay = 1
        
        while retry_count < max_retries:
            try:
                return func(*args, **kwargs)
            except Exception as e:
                retry_count += 1
                if retry_count < max_retries:
                    error_msg = str(e).lower()
                    # Check if this is a transient error
                    if any(keyword in error_msg for keyword in ["maxlag", "timeout", "network"]):
                        self.log_message(f"Attempt {retry_count} failed with transient error. Retrying in {delay} seconds...")
                        time.sleep(delay)
                        delay *= 2  # Exponential backoff
                        continue
                    else:
                        # Non-transient error, don't retry
                        raise e
                else:
                    self.log_message(f"Failed after {max_retries} attempts")
                    raise Exception(f"Failed after {max_retries} attempts: {e}")
        
        return None

    def submit_content(self, page_title: str, content_file: str, edit_summary: str) -> None:
        """Main function to submit content to Arch Wiki."""
        try:
            # Read content from file
            with open(content_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self.log_message(f"Starting Arch Wiki automated submission process for page: {page_title}")
            
            # Step 1: Get login token
            login_tok = self.exponential_backoff(self.get_login_token)
            
            # Step 2: Log in
            self.exponential_backoff(self.login, login_tok)
            
            # Step 3: Get CSRF token
            csrf_tok = self.exponential_backoff(self.get_csrf_token)
            
            # Step 4: Submit the page
            self.exponential_backoff(
                self.submit_wiki_page, 
                page_title, 
                content, 
                edit_summary, 
                csrf_tok
            )
            
            self.log_message("Arch Wiki submission completed successfully!")
            
        except Exception as e:
            self.log_message(f"An unrecoverable error occurred: {e}")
            raise e
        finally:
            # Clean up cookies if desired
            if os.path.exists(COOKIES_FILE):
                os.remove(COOKIES_FILE)
            self.log_message("Script finished.")

def main():
    parser = argparse.ArgumentParser(description='Arch Wiki Automated Submission Script')
    parser.add_argument('page_title', help='Title of the wiki page to edit')
    parser.add_argument('content_file', help='Path to the file containing the content')
    parser.add_argument('edit_summary', nargs='?', default='Automated update for Bluetooth troubleshooting documentation',
                       help='Edit summary for the wiki edit')
    
    args = parser.parse_args()
    
    # Get credentials from environment variables
    username = os.getenv("ARCHWIKI_USERNAME")
    password = os.getenv("ARCHWIKI_PASSWORD")
    
    if not username or not password:
        print("Please set ARCHWIKI_USERNAME and ARCHWIKI_PASSWORD environment variables.")
        sys.exit(1)
    
    # Create bot instance and submit content
    bot = ArchWikiBot(username, password)
    bot.submit_content(args.page_title, args.content_file, args.edit_summary)

if __name__ == "__main__":
    main()