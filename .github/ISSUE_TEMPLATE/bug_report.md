---
name: Bug Report
about: Report a bug or issue with the Realtek Bluetooth fix
title: ''
labels: bug
assignees: ''

---

## Describe the Bug

A clear and concise description of what the bug is.

## To Reproduce

Steps to reproduce the behavior:
1. Go to '...'
2. Run command '....'
3. See error

## Expected Behavior

A clear and concise description of what you expected to happen.

## System Information

- **Linux Distribution**: (e.g., Arch Linux, Ubuntu 22.04, etc.)
- **Kernel Version**: (run `uname -r` to find out)
- **Bluetooth Adapter Model**: (e.g., RTL8822CE, RTL8761BU, etc.)
- **Bluetooth Service Version**: (run `bluetoothd --version`)

## Logs

Please include any relevant logs or error messages:

### Kernel Logs
```bash
sudo dmesg | grep -i bluetooth
```

### Bluetooth Service Logs
```bash
journalctl -u bluetooth --since today
```

## Additional Context

Add any other context about the problem here, such as:
- Have you tried any troubleshooting steps already?
- Did this issue start after a system update?
- Are you using any special Bluetooth configurations?