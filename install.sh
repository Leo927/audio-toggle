#!/bin/bash

# Audio Toggle Extension Installation Script

set -e

EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/audio-toggle@local"
SOURCE_DIR="$(dirname "$0")/audio-toggle@local"

echo "Installing Audio Toggle Extension..."

# Create the extensions directory if it doesn't exist
mkdir -p "$HOME/.local/share/gnome-shell/extensions"

# Check if extension already exists
if [ -d "$EXTENSION_DIR" ]; then
    echo "Extension already exists. Removing old version..."
    rm -rf "$EXTENSION_DIR"
fi

# Copy the extension files
echo "Copying extension files..."
cp -r "$SOURCE_DIR" "$EXTENSION_DIR"

# Set proper permissions
chmod +x "$EXTENSION_DIR"/*.js

echo "Extension installed successfully!"
echo ""
echo "To complete the installation:"
echo "1. Restart GNOME Shell:"
echo "   - Press Alt+F2, type 'r', and press Enter"
echo "   - Or log out and log back in"
echo ""
echo "2. Enable the extension:"
echo "   gnome-extensions enable audio-toggle@local"
echo ""
echo "3. The audio toggle button should appear in your status bar"
echo ""

# Check if pulseaudio tools are available
if ! command -v pactl &> /dev/null; then
    echo "WARNING: pactl (PulseAudio) is not installed or not in PATH"
    echo "Please install pulseaudio-utils:"
    echo "  sudo apt install pulseaudio-utils"
    echo ""
fi

# Try to enable the extension automatically
if command -v gnome-extensions &> /dev/null; then
    echo "Attempting to enable extension automatically..."
    if gnome-extensions enable audio-toggle@local 2>/dev/null; then
        echo "Extension enabled successfully!"
    else
        echo "Could not enable extension automatically. Please enable it manually:"
        echo "  gnome-extensions enable audio-toggle@local"
    fi
else
    echo "gnome-extensions command not found. Please enable the extension manually."
fi

echo ""
echo "Installation complete! 🎉"
