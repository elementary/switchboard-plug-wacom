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

public class Wacom.Backend.DeviceManagerX11 : DeviceManager {
    private Gee.HashMap<Gdk.Device, Device>? devices = null;

    public DeviceManagerX11 () {
        devices = new Gee.HashMap<Gdk.Device, Device> ();

        var seat = Gdk.Display.get_default ().get_default_seat ();
        seat.device_added.connect (add_device);
        seat.device_removed.connect (remove_device);

        var devices = seat.get_devices (Gdk.SeatCapabilities.ALL);
        foreach (var device in devices) {
            add_device (device);
        }
    }

    private void add_device (Gdk.Device gdk_device) {
        // if (gdk_device.type == Gdk.X11.DeviceType.LOGICAL) {
        //     return;
        // }

        int id = -1;
        if (gdk_device is Gdk.X11.DeviceXI2) {
            id = (gdk_device as Gdk.X11.DeviceXI2).device_id;
        } else {
            // id = Gdk.X11.device_get_id ((Gdk.X11.DeviceCore)gdk_device);
        }

        if (id == -1) {
            return;
        }

        var device_file = get_xdevice_node (id);
        if (device_file == null) {
            return;
        }

        var device = devices[gdk_device];
        if (device != null) {
            device_changed (device);
        } else {
            device = create_device (gdk_device, device_file);
            devices[gdk_device] = device;
            device_added (device);
        }
    }

    private static Device create_device (Gdk.Device gdk_device, string device_file) {
        var device = new Backend.Device () {
            device_file = device_file,
            vendor_id = gdk_device.get_vendor_id (),
            product_id = gdk_device.get_product_id (),
            dev_type = get_device_type (gdk_device)
        };

        return device;
    }

    private static Wacom.Backend.Device.DeviceType get_device_type (Gdk.Device device) {
        var source = device.get_source ();
        switch (source) {
            case Gdk.InputSource.MOUSE:
            case Gdk.InputSource.TRACKPOINT:
                return Wacom.Backend.Device.DeviceType.MOUSE;
            case Gdk.InputSource.PEN:
            case Gdk.InputSource.ERASER:
            case Gdk.InputSource.CURSOR:
                if (device.name.contains ("pad")) {
                    return Wacom.Backend.Device.DeviceType.TABLET | Wacom.Backend.Device.DeviceType.PAD;
                }

                return Wacom.Backend.Device.DeviceType.TABLET;
            case Gdk.InputSource.KEYBOARD:
                return Wacom.Backend.Device.DeviceType.KEYBOARD;
            case Gdk.InputSource.TOUCHSCREEN:
                return Wacom.Backend.Device.DeviceType.TOUCHSCREEN;
            case Gdk.InputSource.TOUCHPAD:
                return Wacom.Backend.Device.DeviceType.TOUCHPAD;
            case Gdk.InputSource.TABLET_PAD:
                return Wacom.Backend.Device.DeviceType.TABLET | Wacom.Backend.Device.DeviceType.PAD;
            default:
                return 0;
        }
    }

    private void remove_device (Gdk.Device gdk_device) {
        var device = devices[gdk_device];

        if (device != null) {
            device_removed (device);
            devices.unset (gdk_device);
        }
    }

    private static string? get_xdevice_node (int id) {
        Gdk.Display.get_default ().sync ();

        unowned var display = (Gdk.X11.Display) Gdk.Display.get_default ();
        var prop = display.get_xatom_by_name ("Device Node");

        X.Atom act_type;
        int act_format;
        ulong n_items, bytes_after;
        void* data;

        display.error_trap_push ();

        var ret = XI2.get_property (
            display.get_xdisplay (),
            id,
            prop,
            0,
            1000,
            false,
            X.ANY_PROPERTY_TYPE,
            out act_type,
            out act_format,
            out n_items,
            out bytes_after,
            out data
        );

        if (ret != X.Success) {
            display.error_trap_pop_ignored ();
            return null;
        }

        if (display.error_trap_pop () != 0) {
            return null;
        }

        if (n_items == 0) {
            return null;
        }

        if (act_type != X.XA_STRING) {
            return null;
        }

        if (act_format != 8) {
            return null;
        }

        return (string)data;
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
        return devices[device];
    }

    public static Gdk.DeviceToolType get_tool_type (Gdk.Device device) {
        var tool_type = Gdk.DeviceToolType.UNKNOWN;

        X.Atom act_type;
        int act_format;
        ulong n_items, bytes_after;
        void* data;

        int id = -1;
        if (device is Gdk.X11.DeviceXI2) {
            id = (device as Gdk.X11.DeviceXI2).device_id;
        } else {
            // id = Gdk.X11.device_get_id ((Gdk.X11.DeviceCore)device);
        }

        var display = device.get_display () as Gdk.X11.Display;
        display.error_trap_push ();

        var ret = XI2.get_property (
            display.get_xdisplay (),
            id,
            display.get_xatom_by_name ("Wacom Tool Type"),
            0,
            1,
            false,
            X.XA_ATOM,
            out act_type,
            out act_format,
            out n_items,
            out bytes_after,
            out data
        );

        display.error_trap_pop_ignored ();

        if (ret != X.Success) {
            return tool_type;
        }

        if (act_type != X.XA_ATOM || act_format != 32 || n_items != 1) {
            return tool_type;
        }
        // vala-lint seemingly mistakes * as a multiplication operator. Ignore
        // the error for now, since its a false positive.
        X.Atom device_type = *((X.Atom*)data); // vala-lint=space-before-paren
        if (device_type == 0) {
            return tool_type;
        }

        var name = display.get_xdisplay ().get_atom_name (device_type);
        if (name == "STYLUS") {
            tool_type = Gdk.DeviceToolType.PEN;
        } else if (name == "CURSOR") {
            tool_type = Gdk.DeviceToolType.MOUSE;
        } else if (name == "ERASER") {
            tool_type = Gdk.DeviceToolType.ERASER;
        }

        return tool_type;
    }

}
