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

public class Wacom.StylusView : Gtk.Grid {

    private Backend.WacomTool device;
    private GLib.Settings settings;

    private Gtk.ComboBoxText top_button_combo;

    construct {
        row_spacing = 12;
        column_spacing = 12;

        top_button_combo = new Gtk.ComboBoxText ();
        top_button_combo.hexpand = true;
        top_button_combo.append ("default", _("Default"));
        top_button_combo.append ("middle", _("Middle Mouse Button Click"));
        top_button_combo.append ("right", _("Right Mouse Button Click"));
        top_button_combo.append ("back", _("Back"));
        top_button_combo.append ("forward", _("Forward"));

        attach (new Widgets.SettingLabel (_("Top Button:")), 0, 0);
        attach (top_button_combo, 1, 0);
    }

    public void set_device (Backend.WacomTool dev) {
        device = dev;
        settings = device.get_settings ();

        settings.bind ("button-action", top_button_combo, "active-id", SettingsBindFlags.DEFAULT);
    }
}
