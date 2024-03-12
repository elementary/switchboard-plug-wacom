/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.MainPage : Granite.SimpleSettingsPage {
    private Backend.DeviceManager device_manager;
    private Backend.WacomTool? last_stylus = null;

    private Backend.WacomToolMap tool_map;

    private Granite.Widgets.AlertView placeholder;
    private Gtk.Box main_box;
    private Gtk.Stack stack;
    private Gtk.Stack stylus_stack;
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
        tool_map = Backend.WacomToolMap.get_default ();

        placeholder = new Granite.Widgets.AlertView (
            _("No Tablets Available"),
            _("Please ensure your tablet is connected and switched on"),
            ""
        );
        placeholder.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        placeholder.show_all ();

        var stylus_placeholder = new Granite.Widgets.AlertView (
            _("No Stylus Detected"),
            _("Move the stylus over this window"),
            ""
        );
        stylus_placeholder.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        stylus_placeholder.show_all ();

        tablet_view = new TabletView ();
        stylus_view = new StylusView ();

        stylus_stack = new Gtk.Stack ();
        stylus_stack.add (stylus_view);
        stylus_stack.add_named (stylus_placeholder, "placeholder");

        main_box = new Gtk.Box (VERTICAL, 24);
        main_box.add (tablet_view);
        main_box.add (stylus_stack);

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
        stylus_gesture.proximity.connect (on_stylus);

        update_current_page ();
    }

    private void on_device_added (Backend.Device device) {
        add_known_device (device);
        update_current_page ();
    }

    private void on_device_removed (Backend.Device device) {
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

        var tools = tool_map.list_tools (d);
        if (tools.size > 0) {
            stylus_view.set_device (tools[0]);
        }
     }

    private void update_current_page () {
        foreach (var device in device_manager.list_devices (TABLET)) {
            stack.visible_child = main_box;
            tablet_view.set_device (device);
            return;
        }

        stack.visible_child = placeholder;
    }

    private void on_stylus (double object, double p0) {
        var event = Gtk.get_current_event ();

        var tool = event.get_device_tool ();
        if (tool == null) {
            return;
        }

        var device = device_manager.lookup_gdk_device (event.get_source_device ());
        if (device == null) {
            return;
        }

        var serial = tool.get_serial ();

        var stylus = tool_map.lookup_tool (device, serial);
        if (stylus == null) {
            var id = tool.get_hardware_id ();
            try {
                stylus = new Backend.WacomTool (serial, id, device);
            } catch (GLib.Error e) {
                return;
            }
        }

        tool_map.add_relation (device, stylus);
        if (stylus != last_stylus) {
            stylus_view.set_device (stylus);
            stylus_stack.visible_child = stylus_view;
        }

        last_stylus = stylus;
    }
}
