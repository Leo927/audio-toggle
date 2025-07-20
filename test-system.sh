#!/bin/bash

# Test script to verify audio devices and PulseAudio functionality

echo "🔍 Audio Toggle Extension - System Test"
echo "======================================"
echo

# Test 1: Check if PulseAudio is running
echo "1. Testing PulseAudio availability..."
if command -v pactl &> /dev/null; then
    echo "   ✅ pactl command found"
    
    if pactl info &> /dev/null; then
        echo "   ✅ PulseAudio is running"
    else
        echo "   ❌ PulseAudio is not running"
        echo "   Try: pulseaudio --start"
        exit 1
    fi
else
    echo "   ❌ pactl not found"
    echo "   Please install: sudo apt install pulseaudio-utils"
    exit 1
fi

echo

# Test 2: List available audio sinks
echo "2. Available audio sinks:"
pactl list short sinks | while read line; do
    sink_id=$(echo "$line" | cut -f1)
    sink_name=$(echo "$line" | cut -f2)
    sink_driver=$(echo "$line" | cut -f3)
    
    echo "   ID: $sink_id"
    echo "   Name: $sink_name"
    echo "   Driver: $sink_driver"
    
    # Categorize the device
    if echo "$sink_name" | grep -qi -E "(usb|bluetooth|headset|headphone)"; then
        echo "   Type: 🎧 Headset/Headphones"
    elif echo "$sink_name" | grep -qi -E "(built-in|analog)"; then
        echo "   Type: 🔊 Speakers/Built-in"
    else
        echo "   Type: ❓ Unknown"
    fi
    echo
done

# Test 3: Show current default sink
echo "3. Current default audio sink:"
current_sink=$(pactl info | grep "Default Sink" | cut -d: -f2 | xargs)
echo "   Default: $current_sink"

if echo "$current_sink" | grep -qi -E "(usb|bluetooth|headset|headphone)"; then
    echo "   Currently using: 🎧 Headset/Headphones"
elif echo "$current_sink" | grep -qi -E "(built-in|analog)"; then
    echo "   Currently using: 🔊 Speakers/Built-in"
else
    echo "   Currently using: ❓ Unknown device type"
fi

echo

# Test 4: Check GNOME Shell version
echo "4. GNOME Shell compatibility:"
if command -v gnome-shell &> /dev/null; then
    gnome_version=$(gnome-shell --version | cut -d' ' -f3)
    echo "   GNOME Shell version: $gnome_version"
    
    # Check if version is supported
    major_version=$(echo "$gnome_version" | cut -d. -f1)
    if [ "$major_version" -ge 3 ]; then
        echo "   ✅ Compatible GNOME Shell version"
    else
        echo "   ⚠️  Old GNOME Shell version - may not be compatible"
    fi
else
    echo "   ❌ GNOME Shell not found"
fi

echo

# Test 5: Check if extension directory exists
echo "5. Extension installation check:"
extension_dir="$HOME/.local/share/gnome-shell/extensions/audio-toggle@local"
if [ -d "$extension_dir" ]; then
    echo "   ✅ Extension directory exists"
    
    # Check required files
    required_files=("extension.js" "metadata.json")
    for file in "${required_files[@]}"; do
        if [ -f "$extension_dir/$file" ]; then
            echo "   ✅ $file found"
        else
            echo "   ❌ $file missing"
        fi
    done
else
    echo "   ❌ Extension not installed"
    echo "   Run: ./install.sh"
fi

echo

# Test 6: Test audio switching simulation
echo "6. Testing audio switching commands:"
echo "   (This will not actually change your audio, just test the commands)"

# Test headset detection
headset_sinks=$(pactl list short sinks | grep -E "(usb|bluetooth|headset|headphone)" | head -1)
if [ -n "$headset_sinks" ]; then
    headset_name=$(echo "$headset_sinks" | cut -f2)
    echo "   ✅ Headset device found: $headset_name"
else
    echo "   ⚠️  No headset device found"
fi

# Test speaker detection  
speaker_sinks=$(pactl list short sinks | grep -E "(built-in|analog)" | head -1)
if [ -n "$speaker_sinks" ]; then
    speaker_name=$(echo "$speaker_sinks" | cut -f2)
    echo "   ✅ Speaker device found: $speaker_name"
else
    echo "   ⚠️  No built-in speaker device found"
fi

echo
echo "🎉 System test complete!"
echo
echo "If you see any ❌ errors above, please address them before using the extension."
echo "If you see ⚠️  warnings, the extension may still work but with limited functionality."
