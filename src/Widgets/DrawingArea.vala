/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.Widgets.DrawingArea : Gtk.DrawingArea {
    private Cairo.ImageSurface? surface = null;
    private Cairo.Context? cr = null;

    private Gdk.Device? current_device = null;

    construct {
        add_events (
            Gdk.EventMask.BUTTON_PRESS_MASK |
            Gdk.EventMask.BUTTON_RELEASE_MASK |
            Gdk.EventMask.POINTER_MOTION_MASK
        );
    }

    public override void size_allocate (Gtk.Allocation alloc) {
        ensure_drawing_surface (alloc.width, alloc.height);
        base.size_allocate (alloc);
    }

    public override void map () {
        base.map ();

        Gtk.Allocation allocation;
        get_allocation (out allocation);

        ensure_drawing_surface (allocation.width, allocation.height);
    }

    public void clear () {
        Gtk.Allocation allocation;
        get_allocation (out allocation);

        ensure_drawing_surface (allocation.width, allocation.height, true);
    }

    private void ensure_drawing_surface (int width, int height, bool force = false) {
        if (surface == null || surface.get_width () != width || surface.get_height () != height || force) {
            var new_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, width, height);

            if (surface != null && !force) {
                var cr = new Cairo.Context (new_surface);
                cr.set_source_surface (surface, 0, 0);
                cr.paint ();
            }

            surface = new_surface;
            cr = new Cairo.Context (surface);
        }
    }

    public override bool draw (Cairo.Context cr) {
        Gtk.Allocation alloc;

        get_allocation (out alloc);
        cr.set_source_rgb (1, 1, 1);
        cr.paint ();

        cr.set_source_surface (surface, 0, 0);
        cr.paint ();

        return false;
    }

    public override bool event (Gdk.Event event) {
        var device = event.get_source_device ();
        if (device == null) {
            return Gdk.EVENT_PROPAGATE;
        }

        var source = device.get_source ();
        var tool = event.get_device_tool ();

        if (source != Gdk.InputSource.PEN && source != Gdk.InputSource.ERASER) {
            return Gdk.EVENT_PROPAGATE;
        }

        if (current_device != null && current_device != device) {
            return Gdk.EVENT_PROPAGATE;
        }

        if (
            event.get_event_type () == Gdk.EventType.BUTTON_PRESS
            && event.button.button == 1
            && current_device == null
        ) {
            current_device = device;
        } else if (
            event.get_event_type () == Gdk.EventType.BUTTON_RELEASE
            && event.button.button == 1
            && current_device != null
        ) {
            cr.new_path ();
            current_device = null;
        } else if (
            event.get_event_type () == Gdk.EventType.MOTION_NOTIFY
            && Gdk.ModifierType.BUTTON1_MASK in event.motion.state
        ) {
            double x, y, pressure;

            event.get_coords (out x, out y);
            event.get_axis (Gdk.AxisUse.PRESSURE, out pressure);

            Gdk.DeviceToolType tool_type = Gdk.DeviceToolType.UNKNOWN;
            if (Utils.is_wayland ()) {
                tool_type = tool.get_tool_type ();
            } else {
                tool_type = Backend.DeviceManagerX11.get_tool_type (device);
            }

            if (tool_type == Gdk.DeviceToolType.ERASER) {
                cr.set_line_width (10 * pressure);
                cr.set_operator (Cairo.Operator.DEST_OUT);
            } else {
                cr.set_line_width (4 * pressure);
                cr.set_operator (Cairo.Operator.SATURATE);
            }

            cr.set_source_rgba (0, 0, 0, pressure);
            cr.line_to (x, y);
            cr.stroke ();

            cr.move_to (x, y);

            queue_draw ();

            return Gdk.EVENT_STOP;
        }

        return Gdk.EVENT_PROPAGATE;
    }
}
