# Linux Realtek Bluetooth Fix

Documentation and firmware fix for Realtek Bluetooth adapter pairing/authentication issues on Linux

## Overview

This repository contains comprehensive documentation and a fix for Realtek Bluetooth adapter authentication failures on Linux systems. The issue typically manifests as "Authentication Failed (0x05)" errors in system logs, preventing successful Bluetooth connections despite the adapter being detected.

## Table of Contents

- [Tutorials](#tutorials)
- [How-To Guides](#how-to-guides)
- [Explanation](#explanation)
- [Reference](#reference)
- [Contributing](#contributing)
- [License](#license)

## Tutorials

### A First-Time Guide to Fixing Your Realtek Bluetooth

This step-by-step guide will help you resolve Realtek Bluetooth authentication issues on your Linux system.

1. **Check Bluetooth Service Status**
   ```bash
   systemctl status bluetooth
   ```

2. **Enable and Start Bluetooth Service**
   ```bash
   sudo systemctl enable bluetooth
   sudo systemctl start bluetooth
   ```

3. **Add User to lp Group**
   ```bash
   sudo usermod -a -G lp $USER
   ```

4. **Enable AutoEnable in Configuration**
   Edit `/etc/bluetooth/main.conf` and ensure:
   ```
   [General]
   AutoEnable=true
   ```

5. **Load Required Kernel Modules**
   ```bash
   sudo modprobe zstd
   sudo modprobe btusb
   ```

6. **Restart Bluetooth Service**
   ```bash
   sudo systemctl restart bluetooth
   ```

7. **Verify Fix**
   ```bash
   bluetoothctl show
   ```

## How-To Guides

### How to Diagnose if You Have This Specific Realtek Issue

1. Check if you have a Realtek Bluetooth adapter:
   ```bash
   lsusb | grep -i bluetooth
   ```

2. Look for "Opcode 0x0c03 failed: -110" errors in kernel logs:
   ```bash
   sudo dmesg | grep -i bluetooth | tail -20
   ```

3. Check if firmware files are compressed with zstd:
   ```bash
   ls /lib/firmware/rtl_bt/ | grep rtl8761
   ```

### How to Manually Install the Firmware

1. Check if zstd module is loaded:
   ```bash
   lsmod | grep zstd
   ```

2. If not loaded, load it:
   ```bash
   sudo modprobe zstd
   ```

3. Restart Bluetooth service:
   ```bash
   sudo systemctl restart bluetooth
   ```

### How to Revert the Fix

If you need to revert the changes:

1. Remove user from lp group:
   ```bash
   sudo gpasswd -d $USER lp
   ```

2. Disable AutoEnable in configuration:
   Edit `/etc/bluetooth/main.conf` and comment out:
   ```
   #AutoEnable=true
   ```

3. Disable Bluetooth service:
   ```bash
   sudo systemctl disable bluetooth
   ```

## Explanation

### The Technical Reasons for Realtek Firmware Failures

The Realtek Bluetooth authentication failure issue is primarily caused by compressed firmware files that require the zstd kernel module to decompress. Modern Realtek Bluetooth adapters (particularly the 88xx series) ship with firmware files compressed using the zstd algorithm to save space.

When the Bluetooth service attempts to load these firmware files, it fails if the zstd kernel module is not loaded, resulting in authentication timeouts and the characteristic "Opcode 0x0c03 failed: -110" error messages in the kernel logs.

The solution involves:
1. Loading the zstd kernel module to enable firmware decompression
2. Ensuring the Bluetooth service is properly configured to auto-enable
3. Verifying the user has appropriate permissions to access Bluetooth hardware

### Why This Issue Occurs

This issue is particularly prevalent in newer Linux distributions that ship with compressed firmware files to reduce disk space usage. However, the kernel modules required to decompress these files are not always loaded by default, leading to the authentication failure.

The issue is often misdiagnosed as a hardware problem or driver incompatibility, when in reality it's a simple missing kernel module issue.

## Reference

### Affected Hardware

This fix applies to Realtek Bluetooth adapters, particularly:

- RTL8822CE
- RTL8761BU
- RTL8821CU
- RTL8723DS
- RTL8822BE

### Configuration File Parameters

Key parameters in `/etc/bluetooth/main.conf`:

- `AutoEnable=true` - Automatically enables Bluetooth adapters
- `DiscoverableTimeout=0` - How long the adapter remains discoverable
- `PairableTimeout=0` - How long the adapter remains pairable

### Command-Line Tool Options

Important commands for troubleshooting:

- `systemctl status bluetooth` - Check Bluetooth service status
- `bluetoothctl show` - Show Bluetooth controller information
- `lsmod | grep bluetooth` - List loaded Bluetooth kernel modules
- `dmesg | grep -i bluetooth` - Check kernel logs for Bluetooth messages
- `lsusb` - List USB devices

### External Resources

- [Arch Wiki Bluetooth Page](https://wiki.archlinux.org/title/Bluetooth)
- [Realtek Linux Driver Documentation](https://github.com/lwfinger/rtl8821cu)
- [Linux Kernel Bluetooth Documentation](https://www.kernel.org/doc/html/latest/driver-api/bluetooth.html)

## Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit pull requests, report issues, or suggest improvements.

If you have a different Realtek adapter model that this fix works for, please let us know by opening an issue or submitting a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Arch Linux community for their extensive documentation
- Thanks to Realtek for their hardware support in Linux
- Thanks to all contributors who have helped improve this fix