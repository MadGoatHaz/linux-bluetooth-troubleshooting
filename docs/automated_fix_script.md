# Automated Bluetooth Fix Script

This document contains the automated script to fix Realtek Bluetooth authentication issues on Linux systems.

## Script Overview

The script automates the following steps:

1. Check Bluetooth service status
2. Enable and start Bluetooth service if needed
3. Add user to lp group
4. Enable AutoEnable in Bluetooth configuration
5. Load required kernel modules
6. Restart Bluetooth service
7. Verify the fix

## Script Contents

```bash
#!/bin/bash

# fix_bluetooth.sh - Automated fix for Realtek Bluetooth authentication issues
# Usage: sudo ./fix_bluetooth.sh

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo."
   exit 1
fi

echo "Starting Realtek Bluetooth fix..."

# Check current Bluetooth service status
echo "Checking Bluetooth service status..."
systemctl is-active bluetooth >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Bluetooth service is running."
else
    echo "Starting Bluetooth service..."
    systemctl start bluetooth
    if [ $? -eq 0 ]; then
        echo "Bluetooth service started successfully."
    else
        echo "Failed to start Bluetooth service."
        exit 1
    fi
fi

# Enable Bluetooth service to start on boot
echo "Enabling Bluetooth service..."
systemctl enable bluetooth >/dev/null 2>&1
echo "Bluetooth service enabled."

# Add current user to lp group
echo "Adding user to lp group..."
USERNAME=$(logname)
usermod -a -G lp $USERNAME
if [ $? -eq 0 ]; then
    echo "User $USERNAME added to lp group."
else
    echo "Failed to add user to lp group."
fi

# Enable AutoEnable in Bluetooth configuration
echo "Enabling AutoEnable in Bluetooth configuration..."
MAIN_CONF="/etc/bluetooth/main.conf"
if [ -f "$MAIN_CONF" ]; then
    # Check if AutoEnable is already enabled
    grep -q "^AutoEnable=true" "$MAIN_CONF"
    if [ $? -eq 0 ]; then
        echo "AutoEnable is already enabled."
    else
        # Uncomment or add AutoEnable=true
        sed -i 's/#AutoEnable=true/AutoEnable=true/' "$MAIN_CONF"
        # If not found, add it to [General] section
        if ! grep -q "^AutoEnable=true" "$MAIN_CONF"; then
            sed -i '/^\[General\]/a AutoEnable=true' "$MAIN_CONF"
        fi
        echo "AutoEnable enabled in Bluetooth configuration."
    fi
else
    echo "Bluetooth configuration file not found: $MAIN_CONF"
fi

# Load required kernel modules
echo "Loading required kernel modules..."
modprobe zstd
if [ $? -eq 0 ]; then
    echo "zstd module loaded."
else
    echo "Failed to load zstd module."
fi

modprobe btusb
if [ $? -eq 0 ]; then
    echo "btusb module loaded."
else
    echo "Failed to load btusb module."
fi

# Restart Bluetooth service to apply changes
echo "Restarting Bluetooth service..."
systemctl restart bluetooth
if [ $? -eq 0 ]; then
    echo "Bluetooth service restarted successfully."
else
    echo "Failed to restart Bluetooth service."
fi

# Verify the fix
echo "Verifying Bluetooth controller status..."
bluetoothctl show >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Bluetooth controller is accessible."
    echo "Fix completed successfully!"
    echo ""
    echo "Please log out and log back in for group membership changes to take effect."
    echo "If you continue to have issues, please check the system logs:"
    echo "  sudo dmesg | grep -i bluetooth"
    echo "  journalctl -u bluetooth --since today"
else
    echo "There may be an issue with the Bluetooth controller."
    echo "Please check the system logs for more information:"
    echo "  sudo dmesg | grep -i bluetooth"
    echo "  journalctl -u bluetooth --since today"
fi
```

## Usage Instructions

1. Save the script to a file named `fix_bluetooth.sh`
2. Make it executable:
   ```bash
   chmod +x fix_bluetooth.sh
   ```
3. Run the script with sudo:
   ```bash
   sudo ./fix_bluetooth.sh
   ```

## Manual Steps Required

After running the script, you may need to:

1. Log out and log back in for group membership changes to take effect
2. Check system logs if issues persist:
   ```bash
   sudo dmesg | grep -i bluetooth
   journalctl -u bluetooth --since today
   ```

## Troubleshooting

If the script doesn't resolve your issue:

1. Check that your Realtek Bluetooth adapter is properly detected:
   ```bash
   lsusb | grep -i bluetooth
   ```

2. Verify firmware files are present:
   ```bash
   ls /lib/firmware/rtl_bt/ | grep rtl8761
   ```

3. Check kernel logs for specific error messages:
   ```bash
   sudo dmesg | grep -i bluetooth | tail -20