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

public class Wacom.Backend.WacomTool : GLib.Object {
    public uint64 id { public get; construct; }
    public uint64 serial { public get; construct; }
    public WacomDevice? device { public get; construct; }

    private unowned Wacom.Stylus? wstylus = null;
    private GLib.Settings? settings = null;

    private static Wacom.DeviceDatabase? wacom_db = null;

    public string? name {
        get {
            if (wstylus == null) {
                return null;
            }

            return wstylus.get_name ();
        }
    }

    public int num_buttons {
        get {
            if (wstylus == null) {
                return 0;
            }

            return wstylus.get_num_buttons ();
        }
    }

    public bool has_pressure_detection {
        get {
            if (wstylus == null) {
                return false;
            }

            return Wacom.AxisTypeFlags.PRESSURE in wstylus.get_axes ();
        }
    }

    public bool has_eraser {
        get {
            if (wstylus == null) {
                return false;
            }

            return wstylus.has_eraser ();
        }
    }

    public WacomTool (uint64 serial, uint64 id, WacomDevice? device) throws WacomException {
        if (serial == 0 && device != null) {
            var ids = device.wacom_device.get_supported_styli ();
            if (ids.length > 0) {
                id = ids[0];
            }
        }

        Object (id: id, serial: serial, device: device);

        if (wacom_db == null) {
            wacom_db = new Wacom.DeviceDatabase ();
        }

        wstylus = wacom_db.get_stylus_for_id ((int)this.id);

        if (wstylus == null) {
            throw new WacomException.LIBWACOM_ERROR ("Stylus description not found");
        }

        string settings_path;
        if (this.serial == 0) {
            settings_path = "/org/gnome/desktop/peripherals/stylus/default-%s:%s/".printf (
                device.device.vendor_id, device.device.product_id
            );
        } else {
            settings_path = "/org/gnome/desktop/peripherals/stylus/%llx/".printf (this.serial);
        }

        settings = new GLib.Settings.with_path ("org.gnome.desktop.peripherals.tablet.stylus", settings_path);
    }

    public GLib.Settings get_settings () {
        return settings;
    }
}
