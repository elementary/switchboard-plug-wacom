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

public class Wacom.Backend.WacomTool : GLib.Object {
    public uint64 id { get; construct; default = 0; }
    public uint64 serial { get; construct; default = 0; }
    public string settings_path { get; construct; }

    private static Wacom.DeviceDatabase? wacom_db = null;

    public WacomTool (uint64 serial, uint64 id) {
        Object (
            id: id,
            serial: serial,
            settings_path: "/org/gnome/desktop/peripherals/stylus/%llx/".printf (serial)
        );
    }

    public WacomTool.from_device (Backend.Device device) throws WacomException {
        if (wacom_db == null) {
            wacom_db = new Wacom.DeviceDatabase ();
        }

        var error = new Wacom.Error ();
        var wacom_device = wacom_db.get_device_from_path (device.device_file, Wacom.FallbackFlags.NONE, error);
        if (wacom_device == null) {
            throw new WacomException.LIBWACOM_ERROR (error.get_message () ?? "");
        }

        var _id = 0;
        var supported_styli = wacom_device.get_supported_styli ();
        if (supported_styli.length > 0) {
            _id = supported_styli[0];
        }

        Object (
            id: _id,
            settings_path: "/org/gnome/desktop/peripherals/stylus/default-%s:%s/".printf (
                device.vendor_id, device.product_id
            )
        );
    }
}
