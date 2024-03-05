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

public class Wacom.Backend.Device : GLib.Object {
    [Flags]
    public enum DeviceType {
        MOUSE = 1 << 0,
        KEYBOARD = 1 << 1,
        TOUCHPAD = 1 << 2,
        TABLET = 1 << 3,
        TOUCHSCREEN = 1 << 4,
        PAD = 1 << 5
    }

    public string name { get; construct; }
    public string device_file { get; construct; }
    public string vendor_id { get; construct; }
    public string product_id { get; construct; }
    public DeviceType dev_type { get; construct; }

    public GLib.Settings? get_settings () {
        string? schema = null, path = null;

        if (DeviceType.TOUCHSCREEN in dev_type) {
            schema = "org.gnome.desktop.peripherals.touchscreen";
            path = "/org/gnome/desktop/peripherals/touchscreens/%s:%s/".printf (vendor_id, product_id);
        } else if (DeviceType.TABLET in dev_type) {
            schema = "org.gnome.desktop.peripherals.tablet";
            path = "/org/gnome/desktop/peripherals/tablets/%s:%s/".printf (vendor_id, product_id);
        } else if (DeviceType.MOUSE in dev_type || DeviceType.TOUCHPAD in dev_type) {
            schema = "org.gnome.desktop.peripherals.mouse";
        } else if (DeviceType.KEYBOARD in dev_type) {
            schema = "org.gnome.desktop.peripherals.keyboard";
        } else {
            return null;
        }

        if (path != null) {
            return new GLib.Settings.with_path (schema, path);
        } else {
            return new GLib.Settings (schema);
        }
    }

    public static DeviceType get_device_type (Gdk.Device device) {
        var source = device.get_source ();
        switch (source) {
            case Gdk.InputSource.MOUSE:
            case Gdk.InputSource.TRACKPOINT:
                return DeviceType.MOUSE;
            case Gdk.InputSource.PEN:
                return DeviceType.TABLET;
            case Gdk.InputSource.KEYBOARD:
                return DeviceType.KEYBOARD;
            case Gdk.InputSource.TOUCHSCREEN:
                return DeviceType.TOUCHSCREEN;
            case Gdk.InputSource.TOUCHPAD:
                return DeviceType.TOUCHPAD;
            case Gdk.InputSource.TABLET_PAD:
                return DeviceType.TABLET | DeviceType.PAD;
            default:
                return 0;
        }
    }
}
