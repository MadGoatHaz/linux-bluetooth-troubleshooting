# Linux Bluetooth Troubleshooting

This repository contains comprehensive documentation and tools to resolve common Bluetooth authentication issues on Linux systems, particularly focusing on Realtek Bluetooth adapters that experience "Authentication Failed (0x05)" errors.

## Overview

This project addresses common Bluetooth authentication issues on Linux systems, particularly focusing on Realtek Bluetooth adapters that experience "Authentication Failed (0x05)" errors. The solution involves enabling the Bluetooth service, configuring user permissions, adjusting system settings, and ensuring proper firmware loading.

## Quick Start

### Automated Fix Script

Run the automated fix script to resolve common Bluetooth authentication issues:

```bash
chmod +x scripts/fix_bluetooth.sh
sudo ./scripts/fix_bluetooth.sh
```

### Manual Fix Steps

1. **Enable Bluetooth Service**
   ```bash
   sudo systemctl enable bluetooth
   sudo systemctl start bluetooth
   ```

2. **Configure User Permissions**
   ```bash
   sudo usermod -a -G lp $USER
   newgrp lp
   ```

3. **Enable AutoEnable in Configuration**
   ```bash
   sudo sed -i 's/#AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf
   ```

4. **Load Required Zstd Module**
   ```bash
   sudo modprobe zstd
   echo "zstd" | sudo tee /etc/modules-load.d/bluetooth.conf
   ```

5. **Reset Bluetooth Adapter**
   ```bash
   sudo modprobe -r btusb
   sudo modprobe btusb
   sudo systemctl restart bluetooth
   ```

## Security Guidelines

### Arch Wiki Credentials Security

**IMPORTANT**: Never commit actual credentials to version control!

1. **Credentials File**: The `archwiki_credentials.conf` file should NEVER be committed to the repository
2. **.gitignore**: The `.gitignore` file ensures credentials are not accidentally committed
3. **Sample File**: Use `archwiki_credentials.conf.sample` as a template for your credentials
4. **Local Only**: Keep your actual credentials file local and private

To set up your credentials:
```bash
# Copy the sample file
cp archwiki_credentials.conf.sample archwiki_credentials.conf

# Edit with your actual credentials
nano archwiki_credentials.conf
```

### Secure File Permissions

Ensure your credentials file has secure permissions:
```bash
chmod 600 archwiki_credentials.conf
```

## Repository Structure

```
.
├── scripts/
│   ├── fix_bluetooth.sh          # Automated fix script
│   ├── archwiki_api_login.sh     # Arch Wiki API login script
│   ├── archwiki_get_csrf_token.sh # CSRF token retrieval script
│   ├── archwiki_submit_edit.sh   # Edit submission script
│   ├── archwiki_automated_submission.sh # Master orchestration script (Bash)
│   ├── archwiki_automated_submission.py # Master orchestration script (Python)
│   ├── archwiki_secure_submission.sh # Secure submission script (Bash)
│   ├── archwiki_secure_submission.py # Secure submission script (Python)
│   └── README_*.md               # Documentation for automation scripts
├── docs/
│   ├── automated_fix_script.md   # Documentation for the automated fix script
│   └── repository_structure.md   # Overview of the repository structure
├── .github/
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md          # Bug report template
│       └── feature_request.md    # Feature request template
├── .gitignore                    # Security: Ignores credentials and temporary files
├── CONTRIBUTING.md               # Guidelines for contributing
├── LICENSE.md                   # MIT License information
├── SECURITY_GUIDE.md            # Comprehensive security guide
└── README.md                     # This file
```

## Automated Arch Wiki Submission

The repository includes scripts to automate submission of content to the Arch Wiki using the MediaWiki API.

### Standard Automation (File-based Credentials)

#### Bash Version (Recommended for most users)

Setup:
```bash
# Copy credentials file
cp archwiki_credentials.conf.sample archwiki_credentials.conf

# Edit with your actual credentials
nano archwiki_credentials.conf

# Set secure permissions
chmod 600 archwiki_credentials.conf

# Make scripts executable
chmod +x scripts/*.sh
```

Usage:
```bash
# Submit to Arch Wiki
./scripts/archwiki_automated_submission.sh "Bluetooth" "content_file.md" "Edit summary"
```

See `scripts/README_ARCHWIKI_AUTOMATION.md` for detailed documentation.

#### Python Version (Advanced features)

Setup:
```bash
# Set environment variables
export ARCHWIKI_USERNAME="your_username"
export ARCHWIKI_PASSWORD="your_password"

# Make script executable
chmod +x scripts/archwiki_automated_submission.py
```

Usage:
```bash
# Submit to Arch Wiki
python3 scripts/archwiki_automated_submission.py "Bluetooth" "content_file.md" "Edit summary"
```

See `scripts/README_ARCHWIKI_AUTOMATION_PYTHON.md` for detailed documentation.

### Secure Automation (Runtime Credentials)

For maximum security, use the secure submission scripts that prompt for credentials during execution:

#### Bash Version (Secure)

```bash
# Make script executable
chmod +x scripts/archwiki_secure_submission.sh

# Run with secure credential entry
./scripts/archwiki_secure_submission.sh "Bluetooth" "content_file.md" "Edit summary"
```

#### Python Version (Secure)

```bash
# Make script executable
chmod +x scripts/archwiki_secure_submission.py

# Run with secure credential entry
python3 scripts/archwiki_secure_submission.py "Bluetooth" "content_file.md" "Edit summary"
```

See `scripts/README_SECURE_SUBMISSION.md` for detailed documentation on secure submission features.

## Features Comparison

| Feature | Standard Bash | Standard Python | Secure Bash | Secure Python |
|---------|---------------|-----------------|-------------|---------------|
| Credential Storage | File-based | Environment variables | Runtime entry | Runtime entry |
| Memory Clearance | Basic | Enhanced | Custom | Cryptographic |
| Temporary Files | Process ID | Process ID | Process ID | Process ID |
| Automatic Cleanup | ✅ | ✅ | ✅ | ✅ |
| Hidden Input | ❌ | ✅ | ✅ | ✅ |
| Error Handling | Good | Advanced | Basic | Advanced |

## Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.

## Support

For questions about this project or assistance with implementation, please refer to the documentation provided or contact the project maintainers through GitHub issues.

## Success Metrics

This project will be considered successful when:
1. Content helps users resolve Bluetooth issues
2. Documentation is referenced by other technical resources
3. Community engagement is positive and constructive
4. The repository receives positive feedback from the community