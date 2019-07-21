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

    public WacomTool (uint64 serial, uint64 id, WacomDevice? device) {
        Object (id: id, serial: serial, device: device);
    }
}
