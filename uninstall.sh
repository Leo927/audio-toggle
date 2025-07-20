#!/bin/bash

# Uninstall script for Audio Toggle Extension

EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/audio-toggle@local"

echo "Uninstalling Audio Toggle Extension..."

# Disable the extension first
if command -v gnome-extensions &> /dev/null; then
    echo "Disabling extension..."
    gnome-extensions disable audio-toggle@local 2>/dev/null || true
fi

# Remove the extension directory
if [ -d "$EXTENSION_DIR" ]; then
    echo "Removing extension files..."
    rm -rf "$EXTENSION_DIR"
    echo "Extension removed successfully!"
else
    echo "Extension not found in $EXTENSION_DIR"
fi

echo ""
echo "Please restart GNOME Shell to complete the uninstallation:"
echo "- Press Alt+F2, type 'r', and press Enter"
echo "- Or log out and log back in"
echo ""
echo "Uninstallation complete!"
