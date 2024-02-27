/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.Widgets.DrawingArea : Gtk.DrawingArea {
    private Cairo.ImageSurface? surface = null;
    private Cairo.Context? cr = null;

    private Gtk.GestureStylus stylus_gesture;

    construct {
        stylus_gesture = new Gtk.GestureStylus (this);
        stylus_gesture.up.connect (on_up);
        stylus_gesture.motion.connect (on_motion);
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

    private void on_motion (double object, double p0) {
        double x, y, pressure;

        Gtk.get_current_event ().get_coords (out x, out y);
        stylus_gesture.get_axis (PRESSURE, out pressure);

        var tool_type = stylus_gesture.get_device_tool ().get_tool_type ();
        if (tool_type == ERASER) {
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
    }

    private void on_up (double object, double p0) {
        cr.new_path ();
    }
}
