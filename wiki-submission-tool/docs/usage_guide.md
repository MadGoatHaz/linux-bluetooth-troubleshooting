# Wiki Submission Tool Usage Guide

This guide provides detailed instructions on how to use the Wiki Submission Tool for securely submitting content to any MediaWiki-based wiki.

## Prerequisites

Before using the Wiki Submission Tool, ensure you have:

1. A user account on the target wiki with editing permissions
2. The wiki's API endpoint URL (e.g., `https://wiki.archlinux.org/api.php`)
3. Python 3 installed (for Python scripts)
4. Bash shell (for Bash scripts)
5. curl installed
6. OpenSSL installed (for Bash scripts)

## Security Options

The Wiki Submission Tool provides two main approaches for credential handling:

### Secure Automation (Recommended)

For maximum security, use the secure submission scripts that prompt for credentials during execution:

- `wiki_secure_submission.sh` (Bash)
- `wiki_secure_submission.py` (Python)

These scripts provide:
- Runtime credential entry
- Hidden password input
- Immediate memory clearance
- Automatic cleanup

### Standard Automation

For convenience in automated environments, standard automation scripts are available:
- File-based credentials (`wiki_credentials.conf`)
- Environment variable credentials

## Using Secure Submission Scripts

### Python Version

#### Basic Usage
```bash
# Make script executable
chmod +x scripts/wiki_secure_submission.py

# Run with secure credential entry
python3 scripts/wiki_secure_submission.py "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

#### Parameters
1. `wiki_api_url`: The full URL to the wiki's API endpoint
2. `page_title`: The title of the page to edit
3. `content_file`: Path to the file containing the content to submit
4. `edit_summary`: Optional edit summary (defaults to "Automated update for wiki content")

#### Example
```bash
python3 scripts/wiki_secure_submission.py \
  "https://wiki.archlinux.org/api.php" \
  "My Test Page" \
  "documentation.md" \
  "Adding documentation for my project"
```

### Bash Version

#### Basic Usage
```bash
# Make script executable
chmod +x scripts/wiki_secure_submission.sh

# Run with secure credential entry
./scripts/wiki_secure_submission.sh "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

#### Parameters
1. `wiki_api_url`: The full URL to the wiki's API endpoint
2. `page_title`: The title of the page to edit
3. `content_file`: Path to the file containing the content to submit
4. `edit_summary`: Optional edit summary (defaults to "Automated update for wiki content")

#### Example
```bash
./scripts/wiki_secure_submission.sh \
  "https://wiki.archlinux.org/api.php" \
  "My Test Page" \
  "documentation.md" \
  "Adding documentation for my project"
```

## Using Standard Automation Scripts

### File-Based Credentials

#### Setup
1. Copy the sample credentials file:
   ```bash
   cp wiki_credentials.conf.sample wiki_credentials.conf
   ```

2. Edit the credentials file with your actual credentials:
   ```bash
   nano wiki_credentials.conf
   ```

3. Set secure permissions:
   ```bash
   chmod 600 wiki_credentials.conf
   ```

#### Usage
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Submit to wiki
./scripts/wiki_automated_submission.sh "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

### Environment Variable Credentials

#### Setup
Set environment variables:
```bash
export WIKI_API_URL="https://wiki.archlinux.org/api.php"
export WIKI_USERNAME="your_username"
export WIKI_PASSWORD="your_password"
```

#### Usage
```bash
# Make script executable
chmod +x scripts/wiki_automated_submission.py

# Submit to wiki
python3 scripts/wiki_automated_submission.py "Page Title" "content_file.md" "Edit summary"
```

## Content File Format

The content file should contain valid wiki markup. For MediaWiki, this typically includes:

### Headings
```markdown
==Section Title==
===Subsection Title===
```

### Lists
```markdown
* Unordered list item
* Another item

# Ordered list item
# Another item
```

### Links
```markdown
[[Internal Page]]
[https://example.com External Link]
```

### Code Blocks
```markdown
<pre>
Code example
</pre>

<code>
Inline code
</code>
```

### Templates
```markdown
{{Template Name|parameter1=value1|parameter2=value2}}
```

## Error Handling

The tool provides comprehensive error handling:

### Common Errors

1. **Authentication Failed**: Check your username and password
2. **CSRF Token Invalid**: The tool will automatically retry with a fresh token
3. **Wiki Lagging**: The tool implements exponential backoff for retry
4. **Spam Detection**: Review your content for spam-like patterns
5. **Abuse Filter**: Review your content for violations of wiki policies

### Retry Mechanism

The tool automatically retries failed operations with exponential backoff:
- First retry: 1 second delay
- Second retry: 2 second delay
- Third retry: 4 second delay

## Supported Wikis

This tool has been tested with:
- Arch Wiki (https://wiki.archlinux.org)
- Wikipedia (https://en.wikipedia.org)
- Other MediaWiki-based wikis

## Best Practices

### Content Preparation
1. Review content before submission
2. Use appropriate edit summaries
3. Follow wiki formatting guidelines
4. Test with non-critical pages first

### Security
1. Never commit actual credentials to version control
2. Use secure file permissions for credential files
3. Run scripts in secure environments
4. Monitor for unauthorized changes

### Automation
1. Implement error handling in automated workflows
2. Log submission activities for audit purposes
3. Test automation thoroughly before deployment
4. Monitor for rate limiting

## Troubleshooting

### Script Won't Execute
Ensure the script has execute permissions:
```bash
chmod +x script_name.sh
```

### Missing Dependencies
Install required dependencies:
```bash
# For Python scripts
pip install requests

# For Bash scripts (typically pre-installed)
sudo apt-get install curl openssl
```

### Authentication Issues
1. Verify your username and password
2. Check if your account has editing permissions
3. Ensure the wiki API endpoint is correct

### Content Issues
1. Check for invalid wiki markup
2. Verify content doesn't trigger spam filters
3. Ensure content complies with wiki policies

## Examples

### Submitting Documentation
```bash
python3 scripts/wiki_secure_submission.py \
  "https://wiki.archlinux.org/api.php" \
  "My Project Documentation" \
  "docs/project_documentation.md" \
  "Initial documentation for my project"
```

### Updating a Page
```bash
./scripts/wiki_secure_submission.sh \
  "https://en.wikipedia.org/api.php" \
  "User:MyUsername/Sandbox" \
  "sandbox_updates.md" \
  "Updating my sandbox page"
```

## Advanced Usage

### Batch Processing
Create a script to submit multiple pages:
```bash
#!/bin/bash
pages=("Page1.md" "Page2.md" "Page3.md")
for page in "${pages[@]}"; do
  python3 scripts/wiki_secure_submission.py \
    "https://wiki.archlinux.org/api.php" \
    "${page%.md}" \
    "$page" \
    "Automated update"
done
```

### Integration with CI/CD
Use environment variables in CI/CD pipelines:
```bash
# In your CI/CD configuration
export WIKI_API_URL="https://wiki.archlinux.org/api.php"
export WIKI_USERNAME="$WIKI_USER"
export WIKI_PASSWORD="$WIKI_PASS"

# In your build script
python3 scripts/wiki_automated_submission.py "Page Title" "content.md" "Build $BUILD_NUMBER"