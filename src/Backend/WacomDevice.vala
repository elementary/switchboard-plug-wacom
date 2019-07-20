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

public class Wacom.Backend.WacomDevice : GLib.Object {
    public Device device { private get; construct; }
    private Wacom.Device? wacom_device = null;

    private static Wacom.DeviceDatabase? wacom_db = null;

    static construct {
        wacom_db = new Wacom.DeviceDatabase ();
    }

    public WacomDevice (Device device) {
        Object (device: device);
    }

    construct {
        wacom_device = wacom_db.get_device_from_path (device.device_file);
        warning (wacom_device.get_class ().to_string ());
    }
}
