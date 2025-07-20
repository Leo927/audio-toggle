const { Adw, Gtk, Gio } = imports.gi;

function init() {
}

function fillPreferencesWindow(window) {
    // Create a preferences page
    const page = new Adw.PreferencesPage({
        title: 'Audio Toggle Settings',
        icon_name: 'audio-speakers-symbolic',
    });
    
    const group = new Adw.PreferencesGroup({
        title: 'Device Detection',
        description: 'Configure how audio devices are detected and switched',
    });
    
    // Add preference for headset detection keywords
    const headsetKeywordsRow = new Adw.ActionRow({
        title: 'Headset Keywords',
        subtitle: 'Keywords used to identify headset/headphone devices (comma-separated)',
    });
    
    const headsetEntry = new Gtk.Entry({
        text: 'usb,bluetooth,headset,headphone',
        hexpand: true,
        valign: Gtk.Align.CENTER,
    });
    
    headsetKeywordsRow.add_suffix(headsetEntry);
    
    // Add preference for speaker detection keywords
    const speakerKeywordsRow = new Adw.ActionRow({
        title: 'Speaker Keywords',
        subtitle: 'Keywords used to identify built-in/speaker devices (comma-separated)',
    });
    
    const speakerEntry = new Gtk.Entry({
        text: 'built-in,analog',
        hexpand: true,
        valign: Gtk.Align.CENTER,
    });
    
    speakerKeywordsRow.add_suffix(speakerEntry);
    
    // Add toggle for notifications
    const notificationRow = new Adw.ActionRow({
        title: 'Show Notifications',
        subtitle: 'Display notifications when switching audio outputs',
    });
    
    const notificationSwitch = new Gtk.Switch({
        active: true,
        valign: Gtk.Align.CENTER,
    });
    
    notificationRow.add_suffix(notificationSwitch);
    
    group.add(headsetKeywordsRow);
    group.add(speakerKeywordsRow);
    group.add(notificationRow);
    page.add(group);
    window.add(page);
}
