/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.MainPage : Granite.SimpleSettingsPage {
    private Backend.DeviceManager device_manager;
    private Backend.WacomTool? last_stylus = null;

    private Backend.WacomToolMap tool_map;
    private Gee.HashMap<Backend.Device, Backend.WacomDevice>? devices;

    private Granite.Widgets.AlertView placeholder;
    private Gtk.Box main_box;
    private Gtk.Stack stack;
    private Gtk.GestureStylus stylus_gesture;
    private StylusView stylus_view;
    private TabletView tablet_view;

    public MainPage () {
        Object (
            title: _("Wacom"),
            icon_name: "input-tablet"
        );
    }

    construct {
        devices = new Gee.HashMap<Backend.Device, Backend.WacomDevice> ();
        tool_map = Backend.WacomToolMap.get_default ();

        placeholder = new Granite.Widgets.AlertView (
            _("No Tablets Available"),
            _("Please ensure your tablet is connected and switched on"),
            ""
        );
        placeholder.get_style_context ().remove_class ("view");
        placeholder.show_all ();

        tablet_view = new TabletView ();
        stylus_view = new StylusView ();

        main_box = new Gtk.Box (VERTICAL, 24);
        main_box.add (tablet_view);
        main_box.add (stylus_view);

        stack = new Gtk.Stack ();
        stack.add (main_box);
        stack.add (placeholder);

        content_area.add (stack);

        show_all ();

        device_manager = Backend.DeviceManager.get_default ();
        device_manager.device_added.connect (on_device_added);
        device_manager.device_removed.connect (on_device_removed);

        foreach (var device in device_manager.list_devices (TABLET)) {
            add_known_device (device);
        }

        stylus_gesture = new Gtk.GestureStylus (this);
        stylus_gesture.down.connect (on_stylus);

        update_current_page ();
    }

    private void on_device_added (Backend.Device device) {
        add_known_device (device);
        update_current_page ();
    }

    private void on_device_removed (Backend.Device device) {
        devices.unset (device);
        update_current_page ();
    }

    private void add_known_device (Backend.Device d) {
        if (!(Backend.Device.DeviceType.TABLET in d.dev_type)) {
            return;
        }

        if (Backend.Device.DeviceType.TOUCHSCREEN in d.dev_type ||
            Backend.Device.DeviceType.TOUCHPAD in d.dev_type ||
            Backend.Device.DeviceType.PAD in d.dev_type) {
            return;
        }

        try {
            devices[d] = new Backend.WacomDevice (d);
        } catch (WacomException e) {
            warning ("Error initializing Wacom device: %s", e.message);
            return;
        }

        var tools = tool_map.list_tools (devices[d]);
        if (tools.size > 0) {
            stylus_view.set_device (tools[0]);
        }
     }

    private void update_current_page () {
        foreach (var device in devices.keys) {
            stack.visible_child = main_box;
            tablet_view.set_device (devices[device]);
            return;
        }

        stack.visible_child = placeholder;
    }

    private void on_stylus (double object, double p0) {
        var tool = stylus_gesture.get_device_tool ();
        if (tool == null) {
            return;
        }

        var event = Gtk.get_current_event ();

        var device = device_manager.lookup_gdk_device (event.get_source_device ());
        if (device == null) {
            return;
        }

        var wacom_device = devices[device];
        if (wacom_device == null) {
            return;
        }

        var serial = tool.get_serial ();

        var stylus = tool_map.lookup_tool (wacom_device, serial);
        if (stylus == null) {
            var id = tool.get_hardware_id ();
            try {
                stylus = new Backend.WacomTool (serial, id, wacom_device);
            } catch (GLib.Error e) {
                return;
            }
        }

        tool_map.add_relation (wacom_device, stylus);
        if (stylus != last_stylus) {
            stylus_view.set_device (stylus);
        }

        last_stylus = stylus;
    }
}
