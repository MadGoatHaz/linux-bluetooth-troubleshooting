# Security Guide for Arch Wiki Automation Scripts

This guide explains how to use the Arch Wiki automation scripts safely and securely.

## Security Overview

The automation scripts are designed with security in mind to protect your credentials and ensure safe interaction with the Arch Wiki API. Here's how security is implemented:

### 1. Credential Protection

- **Never committed to version control**: The `.gitignore` file ensures `archwiki_credentials.conf` is never accidentally committed
- **Local storage only**: Credentials are stored locally on your machine
- **Secure permissions**: Recommended file permissions (600) restrict access to your user account only
- **Sample file separation**: `archwiki_credentials.conf.sample` provides a template without real credentials

### 2. Secure Communication

- **HTTPS only**: All communication with the Arch Wiki API uses HTTPS encryption
- **Direct communication**: Credentials are sent directly to the Arch Wiki API, never to third parties
- **Session management**: Temporary session cookies are stored in `/tmp/` and cleaned up automatically

### 3. Automated Security Checks

The scripts include built-in security checks that:
- Verify credentials files are not sample files
- Check file permissions for security
- Validate required fields before submission
- Provide clear error messages for security issues

## Setup Instructions

### 1. Create Your Credentials File

```bash
# Copy the sample file
cp archwiki_credentials.conf.sample archwiki_credentials.conf

# Edit with your actual credentials
nano archwiki_credentials.conf
```

### 2. Set Secure Permissions

```bash
# Set secure permissions (read/write for owner only)
chmod 600 archwiki_credentials.conf
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

## Security Best Practices

### 1. File Permissions

Always use secure file permissions for your credentials file:
```bash
# Check current permissions
stat -c %a archwiki_credentials.conf

# Set secure permissions
chmod 600 archwiki_credentials.conf
```

Recommended permissions:
- `600`: Read/write for owner only (most secure)
- `400`: Read-only for owner (for extra protection)

### 2. Credential Management

- **Never share** your `archwiki_credentials.conf` file
- **Never commit** credentials to version control
- **Regularly review** your Arch Wiki account activity
- **Use strong passwords** for your Arch Wiki account

### 3. Script Execution

- **Review scripts** before running them
- **Monitor output** during execution
- **Check for errors** and handle them appropriately
- **Clean up temporary files** after execution

## Troubleshooting Security Issues

### Common Security Errors

1. **"Credentials file contains sample data"**
   - Solution: Update `archwiki_credentials.conf` with your actual credentials

2. **"File permissions are not secure"**
   - Solution: Run `chmod 600 archwiki_credentials.conf`

3. **"Cookies file not found"**
   - Solution: Run the login script first: `./scripts/archwiki_api_login.sh`

### Security Verification

Verify your setup is secure:
```bash
# Check credentials file exists
ls -la archwiki_credentials.conf

# Check file permissions
stat -c %a archwiki_credentials.conf

# Verify not sample data
grep -v "your_" archwiki_credentials.conf
```

## What Data is Transmitted

### Direct to Arch Wiki API Only

The scripts only transmit data to the official Arch Wiki API:
- **Login credentials**: Username and password (for authentication only)
- **Edit content**: Your documentation content
- **Edit summary**: Description of changes
- **No third-party transmission**: No data is sent to any other services

### Data Never Transmitted

The scripts never transmit:
- Your credentials to third parties
- Your credentials to GitHub or any other service
- Your system information or personal data
- Any data not explicitly shown in the script code

## Emergency Procedures

### If You Suspect Compromise

1. **Change your Arch Wiki password** immediately
2. **Review account activity** on the Arch Wiki
3. **Delete temporary files**: `rm /tmp/archwiki_cookies.txt /tmp/archwiki_csrf_token.txt`
4. **Regenerate credentials file** with a new secure password

### Complete Reset

To completely reset the security setup:
```bash
# Delete temporary files
rm -f /tmp/archwiki_cookies.txt /tmp/archwiki_csrf_token.txt

# Delete credentials file (if compromised)
rm -f archwiki_credentials.conf

# Recreate from sample
cp archwiki_credentials.conf.sample archwiki_credentials.conf
```

## Frequently Asked Questions

### Q: Are my credentials safe?
A: Yes, your credentials are only transmitted directly to the Arch Wiki API using HTTPS encryption.

### Q: Can anyone else access my credentials?
A: Only if they have access to your local machine and can read the credentials file.

### Q: What happens if the script fails?
A: Temporary files are automatically cleaned up, and no partial data is left on the system.

### Q: How can I verify the scripts are secure?
A: Review the source code of all scripts in the `scripts/` directory.

## Reporting Security Issues

If you discover any security issues with these scripts:
1. **Do not post publicly** - Contact the repository maintainers directly
2. **Provide details** - Include the specific issue and potential impact
3. **Suggest fixes** - If possible, provide suggestions for addressing the issue

## Conclusion

The Arch Wiki automation scripts are designed with security as a top priority. By following the guidelines in this document and using the scripts as intended, you can safely automate your Arch Wiki content submissions while keeping your credentials secure.

Remember: **Never commit your actual credentials to version control**, and always verify your setup is secure before running the scripts.