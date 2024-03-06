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

public abstract class Wacom.Backend.DeviceManager : GLib.Object {
    public signal void device_added (Device device);
    public signal void device_removed (Device device);
    public signal void device_changed (Device device);

    private static GLib.Once<DeviceManager> instance;
    public static unowned DeviceManager get_default () {
        return instance.once (() => {
            if (Gdk.Display.get_default () is Gdk.X11.Display) {
                return new DeviceManagerX11 ();
            } else {
                return new DeviceManagerWayland ();
            }
        });
    }

    public abstract Gee.ArrayList<Device> list_devices (Device.DeviceType type);
    public abstract Device? lookup_gdk_device (Gdk.Device device);
}
