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

public class Wacom.TabletView : Gtk.Grid {
    private Backend.WacomDevice device;
    private GLib.Settings settings;

    private Gtk.Switch left_handed_switch;

    construct {
        row_spacing = 12;
        column_spacing = 12;

        left_handed_switch = new Gtk.Switch ();
        left_handed_switch.halign = Gtk.Align.START;

        attach (new Widgets.SettingLabel (_("Left-handed orientation:")), 0, 0);
        attach (left_handed_switch, 1, 0);
    }

    public void set_device (Backend.WacomDevice dev) {
        device = dev;
        settings = device.get_settings ();

        settings.bind ("left-handed", left_handed_switch, "active", SettingsBindFlags.DEFAULT);
    }
}

