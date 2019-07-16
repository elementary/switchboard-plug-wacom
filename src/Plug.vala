/*
 * Copyright (c) 2019 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Wacom.Plug : Switchboard.Plug {

    private Gtk.Stack main_stack;
    private Gtk.ScrolledWindow scrolled;
    private Gtk.Stack empty_stack;

    private StylusView stylus_view;
    private TabletView tablet_view;

    private Backend.DeviceManager device_manager;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("input/pointing/stylus", "general");
        // deprecated
        settings.set ("input/wacom", "general");

        Object (
            category: Category.HARDWARE,
            code_name: "pantheon-wacom",
            display_name: _("Wacom"),
            description: _("Configure Wacom tablet"),
            icon: "input-tablet",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (empty_stack == null) {
            stylus_view = new StylusView ();
            tablet_view = new TabletView ();

            main_stack = new Gtk.Stack ();
            main_stack.margin = 12;
            main_stack.add_titled (stylus_view, "stylus", _("Stylus"));
            main_stack.add_titled (tablet_view, "tablet", _("Tablet"));

            var switcher = new Gtk.StackSwitcher ();
            switcher.halign = Gtk.Align.CENTER;
            switcher.homogeneous = true;
            switcher.margin = 12;
            switcher.stack = main_stack;

            var main_grid = new Gtk.Grid ();
            main_grid.halign = Gtk.Align.CENTER;
            main_grid.attach (switcher, 0, 0);
            main_grid.attach (main_stack, 0, 1);

            scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.add (main_grid);
            scrolled.show_all ();

            var alert_view = new Granite.Widgets.AlertView (
                _("No Tablets Available"),
                _("Please ensure your tablet is connected and switched on"),
                "input-tablet"
            );

            empty_stack = new Gtk.Stack ();
            empty_stack.add_named (scrolled, "main_view");
            empty_stack.add_named (alert_view, "no_tablets");

            empty_stack.show_all ();

            empty_stack.visible_child_name = "no_tablets";

            device_manager = Backend.DeviceManager.get_default ();
            device_manager.device_added.connect (on_device_added);
            device_manager.device_removed.connect (on_device_removed);
        }

        return empty_stack;
    }

    private void on_device_added (Backend.Device device) {

    }

    private void on_device_removed (Backend.Device device) {

    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    /* 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior") */
    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Wacom plug");

    var plug = new Wacom.Plug ();

    return plug;
}


