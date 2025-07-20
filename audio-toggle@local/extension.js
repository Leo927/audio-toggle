const { GObject, St, Clutter, Gio, GLib } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Util = imports.misc.util;

let audioToggle;

const AudioToggleIndicator = GObject.registerClass(
class AudioToggleIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'Audio Toggle');
        
        // Create the icon
        this._icon = new St.Icon({
            icon_name: 'audio-speakers-symbolic',
            style_class: 'system-status-icon'
        });
        
        this.add_child(this._icon);
        
        // Create the menu
        this._createMenu();
        
        // Initialize audio state
        this._currentOutput = 'speaker'; // Default to speaker
        this._updateIcon();
        
        // Check current audio output on startup
        this._getCurrentAudioOutput();
    }
    
    _createMenu() {
        // Add menu items for manual selection
        this._speakerItem = new PopupMenu.PopupMenuItem('🔊 Speakers/Built-in');
        this._speakerItem.connect('activate', () => {
            this._switchToSpeaker();
        });
        this.menu.addMenuItem(this._speakerItem);
        
        this._headsetItem = new PopupMenu.PopupMenuItem('🎧 Headset/Headphones');
        this._headsetItem.connect('activate', () => {
            this._switchToHeadset();
        });
        this.menu.addMenuItem(this._headsetItem);
        
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        
        // Add refresh item
        let refreshItem = new PopupMenu.PopupMenuItem('🔄 Refresh Devices');
        refreshItem.connect('activate', () => {
            this._getCurrentAudioOutput();
        });
        this.menu.addMenuItem(refreshItem);
        
        // Connect the main button click to toggle
        this.connect('button-press-event', (actor, event) => {
            if (event.get_button() === Clutter.BUTTON_PRIMARY) {
                this._toggleAudioOutput();
                return Clutter.EVENT_STOP;
            }
            return Clutter.EVENT_PROPAGATE;
        });
    }
    
    _toggleAudioOutput() {
        if (this._currentOutput === 'speaker') {
            this._switchToHeadset();
        } else {
            this._switchToSpeaker();
        }
    }
    
    _switchToSpeaker() {
        // Get built-in/speaker sinks
        this._executeCommand('pactl list short sinks | grep -E "(built-in|analog)"', (output) => {
            if (output.trim()) {
                let lines = output.trim().split('\n');
                let speakerSink = lines[0].split('\t')[1]; // Get sink name
                this._setDefaultSink(speakerSink);
                this._currentOutput = 'speaker';
                this._updateIcon();
                this._showNotification('Switched to Speakers/Built-in');
            } else {
                // Fallback: try to find any analog output
                this._executeCommand('pactl list short sinks', (allSinks) => {
                    let lines = allSinks.trim().split('\n');
                    if (lines.length > 0) {
                        let fallbackSink = lines[0].split('\t')[1];
                        this._setDefaultSink(fallbackSink);
                        this._currentOutput = 'speaker';
                        this._updateIcon();
                        this._showNotification('Switched to default audio output');
                    }
                });
            }
        });
    }
    
    _switchToHeadset() {
        // Get headset/headphone sinks (usually USB or Bluetooth)
        this._executeCommand('pactl list short sinks | grep -E "(usb|bluetooth|headset|headphone)"', (output) => {
            if (output.trim()) {
                let lines = output.trim().split('\n');
                let headsetSink = lines[0].split('\t')[1]; // Get sink name
                this._setDefaultSink(headsetSink);
                this._currentOutput = 'headset';
                this._updateIcon();
                this._showNotification('Switched to Headset/Headphones');
            } else {
                this._showNotification('No headset/headphone device found');
                // Try to find any non-built-in device
                this._executeCommand('pactl list short sinks | grep -v -E "(built-in|analog)"', (altOutput) => {
                    if (altOutput.trim()) {
                        let lines = altOutput.trim().split('\n');
                        let altSink = lines[0].split('\t')[1];
                        this._setDefaultSink(altSink);
                        this._currentOutput = 'headset';
                        this._updateIcon();
                        this._showNotification('Switched to external audio device');
                    }
                });
            }
        });
    }
    
    _setDefaultSink(sinkName) {
        this._executeCommand(`pactl set-default-sink ${sinkName}`, () => {
            // Also move existing streams to the new sink
            this._executeCommand(`pactl list short sink-inputs | cut -f1`, (inputs) => {
                if (inputs.trim()) {
                    let inputIds = inputs.trim().split('\n');
                    inputIds.forEach(id => {
                        if (id) {
                            this._executeCommand(`pactl move-sink-input ${id} ${sinkName}`, () => {});
                        }
                    });
                }
            });
        });
    }
    
    _getCurrentAudioOutput() {
        this._executeCommand('pactl info | grep "Default Sink"', (output) => {
            if (output.trim()) {
                let defaultSink = output.split(':')[1].trim();
                // Determine if it's a headset or speaker based on sink name
                if (defaultSink.match(/(usb|bluetooth|headset|headphone)/i)) {
                    this._currentOutput = 'headset';
                } else {
                    this._currentOutput = 'speaker';
                }
                this._updateIcon();
            }
        });
    }
    
    _updateIcon() {
        if (this._currentOutput === 'headset') {
            this._icon.icon_name = 'audio-headphones-symbolic';
        } else {
            this._icon.icon_name = 'audio-speakers-symbolic';
        }
        
        // Update menu item highlights
        if (this._speakerItem && this._headsetItem) {
            this._speakerItem.setOrnament(
                this._currentOutput === 'speaker' ? 
                PopupMenu.Ornament.DOT : PopupMenu.Ornament.NONE
            );
            this._headsetItem.setOrnament(
                this._currentOutput === 'headset' ? 
                PopupMenu.Ornament.DOT : PopupMenu.Ornament.NONE
            );
        }
    }
    
    _executeCommand(command, callback) {
        try {
            let proc = Gio.Subprocess.new(
                ['bash', '-c', command],
                Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE
            );
            
            proc.communicate_utf8_async(null, null, (proc, res) => {
                try {
                    let [, stdout, stderr] = proc.communicate_utf8_finish(res);
                    if (callback) {
                        callback(stdout || '');
                    }
                } catch (e) {
                    log(`Audio Toggle Extension: Command failed: ${e.message}`);
                    if (callback) {
                        callback('');
                    }
                }
            });
        } catch (e) {
            log(`Audio Toggle Extension: Failed to execute command: ${e.message}`);
            if (callback) {
                callback('');
            }
        }
    }
    
    _showNotification(message) {
        // Use GNOME Shell's notification system
        Main.notify('Audio Toggle', message);
    }
});

function init() {
    return new Extension();
}

class Extension {
    enable() {
        audioToggle = new AudioToggleIndicator();
        Main.panel.addToStatusArea('audio-toggle', audioToggle);
    }
    
    disable() {
        if (audioToggle) {
            audioToggle.destroy();
            audioToggle = null;
        }
    }
}
