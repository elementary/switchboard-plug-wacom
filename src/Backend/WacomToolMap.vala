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

public class Wacom.Backend.WacomToolMap : GLib.Object {
    private const string GENERIC_STYLUS = "Generic";
    private const string KEY_TOOL_ID = "ID";
    private const string KEY_DEVICE_STYLI = "Styli";

    private GLib.KeyFile tablets;
    private GLib.KeyFile tools;

    private string tablet_path;
    private string tool_path;

    private Gee.HashMap<string, Gee.ArrayList<WacomTool>> tablet_map;
    private Gee.HashMap<string, WacomTool> tool_map;
    private Gee.HashMap<string, WacomTool?> no_serial_tool_map;

    private static Wacom.DeviceDatabase wacom_db;

    private static GLib.Once<WacomToolMap> instance;
    public static unowned WacomToolMap get_default () {
        return instance.once (() => {
            return new WacomToolMap ();
        });
    }

    public WacomToolMap () {
        tablets = new GLib.KeyFile ();
        tools = new GLib.KeyFile ();

        tablet_map = new Gee.HashMap<string, Gee.ArrayList<WacomTool>> ();
        tool_map = new Gee.HashMap<string, WacomTool> ();
        no_serial_tool_map = new Gee.HashMap<string, WacomTool> ();

        load_keyfiles ();
        cache_tools ();
        cache_devices ();
    }

    private void load_keyfiles () {
        var dir = Path.build_filename (Environment.get_user_cache_dir (), "io.elementary.settings", "wacom");

        if (DirUtils.create_with_parents (dir, 0700) < 0) {
            warning ("Could not create directory '%s', stylus mapping may not work well", dir);
            return;
        }

        tablet_path = Path.build_filename (dir, "devices");
        try {
            tablets.load_from_file (tablet_path, KeyFileFlags.NONE);
        } catch (GLib.Error e) {
            warning ("Could not load tablets keyfile '%s': %s", tablet_path, e.message);
        }

        tool_path = Path.build_filename (dir, "tools");
        try {
            tools.load_from_file (tool_path, KeyFileFlags.NONE);
        } catch (GLib.Error e) {
            warning ("Could not load tools keyfile '%s': %s", tool_path, e.message);
        }
    }

    private void cache_tools () {
        var serials = tools.get_groups ();
        for (int i = 0; i < serials.length; i++) {
            uint64 serial, id;
            try {
                if (!uint64.from_string (serials[i], out serial, 16)) {
                    warning ("Invalid tool serial %s", serials[i]);
                    continue;
                }
            } catch (GLib.Error e) {
                warning ("Invalid tool serial %s", serials[i]);
                continue;
            }

            string str;
            try {
                str = tools.get_string (serials[i], KEY_TOOL_ID);
            } catch (GLib.Error e) {
                warning ("Could not get cached ID for tool with serial %s: %s", serials[i], e.message);
                continue;
            }

            try {
                if (!uint64.from_string (str, out id, 16)) {
                    warning ("Invalid tool ID %s", str);
                    continue;
                }
            } catch (GLib.Error e) {
                warning ("Invalid tool ID %s", str);
                continue;
            }

            tool_map[serials[i]] = new WacomTool (serial, id);
        }
    }

    private void cache_devices () {
        var ids = tablets.get_groups ();
        for (int i = 0; i < ids.length; i++) {
            var tools = new Gee.ArrayList<WacomTool> ();

            string[]? styli = null;
            try {
                styli = tablets.get_string_list (ids[i], KEY_DEVICE_STYLI);
            } catch (KeyFileError e) {
                warning ("Could not get cached styli for tablet with id %s: %s", ids[i], e.message);
                continue;
            }

            for (int j = 0; j < styli.length; j++) {
                if (styli[j] == GENERIC_STYLUS) {
                    no_serial_tool_map[ids[i]] = null;
                }

                var tool = tool_map[styli[j]];
                if (tool != null) {
                    tools.add (tool);
                }
            }

            if (tools.size > 0) {
                tablet_map[ids[i]] = tools;
            }
        }
    }

    private static string get_tool_key (uint64 serial) {
        return "%llx".printf (serial);
    }

    public void add_relation (string device_key, WacomTool tool) {
        string tool_key;
        bool tools_changed = false, tablets_changed = false;

        var serial = tool.serial;

        if (serial == 0) {
            tool_key = GENERIC_STYLUS;
            no_serial_tool_map[device_key] = tool;
        } else {
            tool_key = get_tool_key (serial);
            if (!tool_map.has_key (tool_key)) {
                keyfile_add_stylus (tool_key, tool.id);
                tools_changed = true;
                tool_map[tool_key] = tool;
            } else if (tool_map[tool_key] == null) {
                tool_map[tool_key] = tool;
            }
        }

        var styli = tablet_map[device_key];
        if (styli == null) {
            styli = new Gee.ArrayList<WacomTool> ();
            tablet_map[device_key] = styli;
        }

        if (!(tool in styli)) {
            tablets_changed = true;
            keyfile_add_device_stylus (device_key, tool_key);
            styli.add (tool);
        }

        if (tools_changed) {
            try {
                tools.save_to_file (tool_path);
            } catch (FileError e) {
                warning ("Error saving tools keyfile '%s': %s", tool_path, e.message);
            }
        }

        if (tablets_changed) {
            try {
                tablets.save_to_file (tablet_path);
            } catch (FileError e) {
                warning ("Error saving tablets keyfile '%s': %s", tablet_path, e.message);
            }
        }
    }

    private void keyfile_add_device_stylus (string device_key, string tool_key) {
        string[]? styli = null;
        try {
            styli = tablets.get_string_list (device_key, KEY_DEVICE_STYLI);
        } catch (KeyFileError e) {

        }

        if (styli == null) {
            styli = new string[] {};
        }

        styli += tool_key;
        tablets.set_string_list (device_key, KEY_DEVICE_STYLI, styli);
    }

    private void keyfile_add_stylus (string tool_key, uint64 id) {
        var str = get_tool_key (id);
        tools.set_string (tool_key, KEY_TOOL_ID, str);
    }

    public WacomTool? lookup_tool (uint64 serial, string device_key) {
        if (serial == 0) {
            return no_serial_tool_map[device_key];
        } else {
            return tool_map[get_tool_key (serial)];
        }
    }

    public Gee.ArrayList<WacomTool> list_tools (Backend.Device device) throws WacomException {
        var styli = new Gee.ArrayList<WacomTool> ();

        var key = "%s:%s".printf (device.vendor_id, device.product_id);
        var tablet_tools = tablet_map[key];
        if (tablet_tools != null) {
            styli.add_all (tablet_map[key]);
        }

        if (no_serial_tool_map.has_key (key)) {
            var no_serial_tool = no_serial_tool_map[key];
            if (no_serial_tool == null) {
                if (wacom_db == null) {
                    wacom_db = new Wacom.DeviceDatabase ();
                }

                var error = new Wacom.Error ();
                var wacom_device = wacom_db.get_device_from_path (device.device_file, Wacom.FallbackFlags.NONE, error);
                if (wacom_device == null) {
                    throw new WacomException.LIBWACOM_ERROR (error.get_message () ?? "");
                }

                var id = 0;
                var supported_styli = wacom_device.get_supported_styli ();
                if (supported_styli.length > 0) {
                    id = supported_styli[0];
                }

                var settings_path = "/org/gnome/desktop/peripherals/stylus/default-%s:%s/".printf (
                    device.vendor_id, device.product_id
                );

                no_serial_tool = new WacomTool (0, id, settings_path);
                no_serial_tool_map[key] = no_serial_tool;
            }

            styli.add (no_serial_tool);
        }

        return styli;
    }
}
