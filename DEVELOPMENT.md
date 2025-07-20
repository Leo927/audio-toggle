# Audio Toggle Extension - Development Guide

## Project Structure

```
audio-toggle/
├── audio-toggle@local/           # Main extension directory
│   ├── extension.js             # Core extension logic
│   ├── metadata.json            # Extension metadata
│   ├── prefs.js                # Preferences window
│   └── stylesheet.css           # Styling
├── install.sh                   # Installation script
├── uninstall.sh                # Uninstallation script
├── DEVELOPMENT.md               # This file
└── README.md                   # User documentation
```

## How It Works

### Extension Architecture

The extension is built as a GNOME Shell extension that:

1. **Creates a status bar indicator** using `PanelMenu.Button`
2. **Integrates with PulseAudio** via `pactl` commands
3. **Provides visual feedback** through icon changes and notifications
4. **Offers a dropdown menu** for manual device selection

### Key Components

#### AudioToggleIndicator Class
- Extends `PanelMenu.Button` to create the status bar widget
- Manages the audio device switching logic
- Handles UI updates and user interactions

#### Audio Detection Logic
- Uses `pactl` commands to query available audio sinks
- Categorizes devices as "headset" or "speaker" based on keywords
- Supports automatic detection and manual override

#### Device Categories
- **Speakers/Built-in**: Devices matching keywords like "built-in", "analog"
- **Headset/Headphones**: Devices matching "usb", "bluetooth", "headset", "headphone"

## Development Setup

### Prerequisites
```bash
sudo apt update
sudo apt install gjs libgjs-dev pulseaudio-utils
```

### Testing During Development

1. **Install the extension**:
   ```bash
   ./install.sh
   ```

2. **View logs** (useful for debugging):
   ```bash
   journalctl -f -o cat /usr/bin/gnome-shell
   ```

3. **Restart GNOME Shell** after making changes:
   - Press `Alt + F2`
   - Type `r` and press Enter

4. **Test PulseAudio commands** manually:
   ```bash
   # List available sinks
   pactl list short sinks
   
   # Get current default sink
   pactl info | grep "Default Sink"
   
   # Set default sink
   pactl set-default-sink SINK_NAME
   ```

### Debugging

#### Common Issues
1. **Extension not loading**: Check `journalctl` for JavaScript errors
2. **No devices found**: Verify `pactl` commands work manually
3. **Icon not updating**: Check if icon names are valid

#### Debug Commands
```bash
# Check if extension is enabled
gnome-extensions list --enabled | grep audio-toggle

# View extension info
gnome-extensions info audio-toggle@local

# Enable/disable manually
gnome-extensions enable audio-toggle@local
gnome-extensions disable audio-toggle@local
```

## Code Structure

### extension.js
- **_init()**: Sets up the UI and initializes state
- **_createMenu()**: Creates dropdown menu with device options
- **_toggleAudioOutput()**: Main toggle function
- **_switchToSpeaker()/_switchToHeadset()**: Device-specific switching
- **_executeCommand()**: Async command execution wrapper
- **_getCurrentAudioOutput()**: Detects current audio state

### PulseAudio Integration
The extension uses these key `pactl` commands:
- `pactl list short sinks`: Get available audio outputs
- `pactl info | grep "Default Sink"`: Get current default
- `pactl set-default-sink SINK`: Set new default
- `pactl move-sink-input INPUT SINK`: Move active streams

## Customization

### Device Detection Keywords
Modify the keyword matching in `_switchToSpeaker()` and `_switchToHeadset()`:
```javascript
// For speakers
.grep -E "(built-in|analog)"

// For headsets  
.grep -E "(usb|bluetooth|headset|headphone)"
```

### Icon Changes
Update icon names in `_updateIcon()`:
```javascript
// Available icons (check your theme)
'audio-speakers-symbolic'
'audio-headphones-symbolic'
'audio-card-symbolic'
```

### Notification Messages
Modify notification text in the `_showNotification()` calls.

## Contributing

1. **Test thoroughly** on different Ubuntu/GNOME versions
2. **Check PulseAudio compatibility** with various audio setups
3. **Validate device detection** with different hardware configurations
4. **Follow GNOME Shell extension best practices**

## Troubleshooting

### Extension Won't Load
- Check GNOME Shell version compatibility in `metadata.json`
- Verify no syntax errors in JavaScript files
- Ensure proper file permissions

### Audio Switching Doesn't Work
- Test `pactl` commands manually
- Check if PulseAudio is running: `pulseaudio --check`
- Verify audio devices are detected: `pactl list short sinks`

### Icons Not Showing
- Check if icon theme includes the required symbolic icons
- Test with different icon names
- Verify GNOME Shell icon loading works
