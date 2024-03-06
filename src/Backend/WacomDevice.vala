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

public errordomain WacomException {
    LIBWACOM_ERROR
}

public class Wacom.Backend.WacomDevice : GLib.Object {
    private const string WACOM_TABLET_SCHEMA = "org.gnome.desktop.peripherals.tablet";
    private const string WACOM_SETTINGS_BASE = "/org/gnome/desktop/peripherals/tablets/%s:%s/";

    public Device device { public get; construct; }
    private GLib.Settings? wacom_settings = null;

    public WacomDevice (Device device) throws WacomException {
        Object (device: device);
    }

    public GLib.Settings get_settings () {
        if (wacom_settings == null) {
            var path = WACOM_SETTINGS_BASE.printf (device.vendor_id, device.product_id);
            wacom_settings = new GLib.Settings.with_path (WACOM_TABLET_SCHEMA, path);
        }

        return wacom_settings;
    }
}
