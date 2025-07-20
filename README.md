# Audio Toggle Extension

A GNOME Shell extension that adds a toggle button to the Ubuntu status bar for switching between headset and speaker/built-in audio outputs.


<img width="234" height="187" alt="image" src="https://github.com/user-attachments/assets/acd933e1-ae0a-4d80-a4aa-469b3e760cb5" />


## Features

- Toggle button in the status bar that shows current audio output
- Visual indication of current output (headset 🎧 or speaker 🔊)
- Easy switching between audio devices
- Automatic detection of available audio outputs

## Installation

1. Install required dependencies:
   ```bash
   sudo apt update
   sudo apt install gjs libgjs-dev
   ```

2. Copy the extension to the GNOME extensions directory:
   ```bash
   cp -r audio-toggle@local ~/.local/share/gnome-shell/extensions/
   ```

3. Restart GNOME Shell:
   - Press `Alt + F2`
   - Type `r` and press Enter
   - Or log out and log back in

4. Enable the extension:
   ```bash
   gnome-extensions enable audio-toggle@local
   ```

## Usage

- Click the audio icon in the status bar to toggle between headset and speaker outputs
- The icon changes to indicate the current output:
  - 🎧 for headset/headphones
  - 🔊 for speakers/built-in audio

## Development

The extension is built using:
- JavaScript (GJS)
- GNOME Shell APIs
- PulseAudio integration via command line tools

## File Structure

```
audio-toggle/
├── audio-toggle@local/
│   ├── extension.js      # Main extension logic
│   ├── metadata.json     # Extension metadata
│   ├── prefs.js         # Preferences window
│   └── stylesheet.css   # UI styling
├── install.sh           # Installation script
├── uninstall.sh         # Uninstallation script
├── test-system.sh       # System compatibility test
├── Makefile             # Build and development tools
├── package.json         # Node.js project metadata
├── DEVELOPMENT.md       # Developer documentation
├── audio-toggle.desktop # Desktop entry file
└── README.md           # This file
```

## Quick Start

1. **Test your system**:
   ```bash
   ./test-system.sh
   ```

2. **Install the extension**:
   ```bash
   make install enable
   ```
   Or use the install script:
   ```bash
   ./install.sh
   ```

3. **Restart GNOME Shell**:
   - Press `Alt + F2`, type `r`, and press Enter
   - Or log out and log back in

## Development

For developers who want to modify or contribute to the extension:

```bash
# Install in development mode with log watching
make dev

# Run tests
make test

# Reinstall after changes
make reinstall
```

See `DEVELOPMENT.md` for detailed development information.
