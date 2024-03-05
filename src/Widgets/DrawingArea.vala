/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.Widgets.DrawingArea : Gtk.DrawingArea {
    private Cairo.ImageSurface? surface = null;
    private Cairo.Context? cr = null;

    private Gtk.GestureStylus stylus_gesture;

    construct {
        stylus_gesture = new Gtk.GestureStylus ();
        stylus_gesture.up.connect (on_up);
        stylus_gesture.motion.connect (on_motion);

        add_controller (stylus_gesture);
    }

    public override void size_allocate (int width, int height, int baseline) {
        ensure_drawing_surface (width, height);
        base.size_allocate (width, height, baseline);
    }

    public override void map () {
        base.map ();

        ensure_drawing_surface (get_width (), get_height ());
        set_draw_func (draw_func);
    }

    public void clear () {
        ensure_drawing_surface (get_width (), get_height (), true);
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

    private void draw_func (Gtk.DrawingArea drawing_area, Cairo.Context cr, int width, int height) {
        cr.set_source_rgb (1, 1, 1);
        cr.paint ();

        cr.set_source_surface (surface, 0, 0);
        cr.paint ();
    }

    private void on_motion (double object, double p0) {
        double x, y, pressure;

        // Gtk.get_current_event ().get_coords (out x, out y);
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
