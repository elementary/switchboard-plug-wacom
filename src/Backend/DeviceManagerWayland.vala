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

public class Wacom.Backend.DeviceManagerWayland : DeviceManager {
    private Gee.HashMap<GUdev.Device, Device>? devices = null;
    private GUdev.Client? client = null;

    private struct UdevIDTable {
        string udev_id;
        Device.DeviceType device_type;
    }
    const UdevIDTable[] UDEV_ID_TABLE = {
        { "ID_INPUT_MOUSE", Device.DeviceType.MOUSE },
        { "ID_INPUT_KEYBOARD", Device.DeviceType.KEYBOARD },
        { "ID_INPUT_TOUCHPAD", Device.DeviceType.TOUCHPAD },
        { "ID_INPUT_TABLET", Device.DeviceType.TABLET },
        { "ID_INPUT_TOUCHSCREEN", Device.DeviceType.TOUCHSCREEN },
        { "ID_INPUT_TABLET_PAD", Device.DeviceType.PAD },
    };

    public DeviceManagerWayland () {
        devices = new Gee.HashMap<GUdev.Device, Device> ();

        string[] subsystems = new string[] { "input" };

        client = new GUdev.Client (subsystems);
        client.uevent.connect (on_uevent);

        var devices = client.query_by_subsystem (subsystems[0]);
        foreach (var device in devices) {
            if (device_is_evdev (device)) {
                add_device (device);
            }
        }
    }

    private void on_uevent (string action, GUdev.Device device) {
        if (!device_is_evdev (device)) {
            return;
        }

        if (action == "add") {
            add_device (device);
        } else if (action == "remove") {
            remove_device (device);
        }
    }

    private static bool device_is_evdev (GUdev.Device device) {
        var device_file = device.get_device_file ();
        if (device_file == null || !device_file.contains ("/event")) {
            return false;
        }

        return device.get_property_as_boolean ("ID_INPUT");
    }

    private void add_device (GUdev.Device udev_device) {
        var parent = udev_device.get_parent ();
        if (parent == null) {
            return;
        }

        var device = create_device (udev_device);
        if (device == null) {
            return;
        }

        devices[udev_device] = device;
        device_added (device);
    }

    private void remove_device (GUdev.Device udev_device) {
        var device = devices[udev_device];
        if (device == null) {
            return;
        }

        device_removed (device);
        devices.unset (udev_device);
    }

    private static Device.DeviceType get_udev_device_type (GUdev.Device device) {
        Device.DeviceType type = 0;
        for (int i = 0; i < UDEV_ID_TABLE.length; i++) {
            if (device.get_property_as_boolean (UDEV_ID_TABLE[i].udev_id)) {
                type |= UDEV_ID_TABLE[i].device_type;
            }
        }

        return type;
    }

    private Device? create_device (GUdev.Device udev_device) {
        var type = get_udev_device_type (udev_device);
        if (type == Device.DeviceType.KEYBOARD) {
            return null;
        }

        var parent = udev_device.get_parent ();
        if (parent == null) {
            return null;
        }

        var vendor = udev_device.get_property ("ID_VENDOR_ID");
        var product = udev_device.get_property ("ID_PRODUCT_ID");

        if (vendor == null || product == null) {
            vendor = udev_device.get_sysfs_attr ("device/id/vendor");
            product = udev_device.get_sysfs_attr ("device/id/product");
        }

        var device = new Backend.Device () {
            device_file = udev_device.get_device_file (),
            vendor_id = vendor,
            product_id = product,
            dev_type = type
        };

        return device;
    }

    public override Gee.ArrayList<Device> list_devices (Device.DeviceType type) {
        var result = new Gee.ArrayList<Device> ();
        foreach (var device in devices.values) {
            if (type in device.dev_type) {
                result.add (device);
            }
        }

        return result;
    }

    public override Device? lookup_gdk_device (Gdk.Device device) {
        Gdk.Wayland.Device? wayland_device = (device as Gdk.Wayland.Device);
        if (wayland_device == null) {
            return null;
        }

        var node_path = wayland_device.get_node_path ();
        if (node_path == null) {
            return null;
        }

        foreach (var dev in devices.values) {
            if (dev.device_file == node_path) {
                return dev;
            }
        }

        return null;
    }
}
