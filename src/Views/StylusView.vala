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

public class Wacom.StylusView : Gtk.Stack {

    private const int32[,] PRESSURE_CURVES = {
        { 0, 75, 25, 100 }, /* soft */
        { 0, 50, 50, 100 },
        { 0, 25, 75, 100 },
        { 0, 0, 100, 100 }, /* neutral */
        { 25, 0, 100, 75 },
        { 50, 0, 100, 50 },
        { 75, 0, 100, 25 }  /* firm */
    };

    private Backend.WacomTool device;
    private GLib.Settings settings;

    private Gtk.Grid stylus_grid;
    private int last_grid_y_pos = 0;

    construct {
        stylus_grid = new Gtk.Grid ();
        stylus_grid.row_spacing = 12;
        stylus_grid.column_spacing = 12;

        var no_stylus_view = new Granite.Widgets.AlertView (
            _("No Stylus Detected"),
            _("Please move your stylus close to the tablet"),
            "input-tablet"
        );
        no_stylus_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        add_named (stylus_grid, "stylus");
        add_named (no_stylus_view, "no_stylus");

        show_all ();

        visible_child_name = "no_stylus";
    }

    private void build_button_settings (string label, string schema_key) {
        var button_combo = new Gtk.ComboBoxText ();
        button_combo.hexpand = true;
        button_combo.append ("default", _("Default"));
        button_combo.append ("middle", _("Middle Mouse Button Click"));
        button_combo.append ("right", _("Right Mouse Button Click"));
        button_combo.append ("back", _("Back"));
        button_combo.append ("forward", _("Forward"));

        settings.bind (schema_key, button_combo, "active-id", SettingsBindFlags.DEFAULT);
        stylus_grid.attach (new Widgets.SettingLabel (label), 0, last_grid_y_pos);
        stylus_grid.attach (button_combo, 1, last_grid_y_pos);
        last_grid_y_pos++;
    }

    private void on_pressure_value_changed (Gtk.Scale scale, string schema_key) {
        var new_value = (int)scale.get_value ();
        if (new_value < 0 || new_value > 6) {
            return;
        }

        Variant[] values = new Variant[PRESSURE_CURVES.length[1]];
        Variant array;

        for (int i = 0; i < values.length; i++) {
            values[i] = new Variant.int32 (PRESSURE_CURVES[new_value, i]);
        }

        array = new Variant.array (VariantType.INT32, values);
        settings.set_value (schema_key, array);
    }

    private void set_pressure_scale_value_from_settings (Gtk.Scale scale, string schema_key) {
        var settings_value = settings.get_value (schema_key);
        if (settings_value.n_children () != PRESSURE_CURVES.length[1]) {
            warning ("Invalid pressure curve format, expected %d values", PRESSURE_CURVES.length[1]);
            return;
        }

        int[] values = new int[PRESSURE_CURVES.length[1]];
        for (int i = 0; i < PRESSURE_CURVES.length[1]; i++) {
            values[i] = settings_value.get_child_value (i).get_int32 ();
        }

        for (int i = 0; i < PRESSURE_CURVES.length[0]; i++) {
            bool match = true;
            for (int j = 0; j < PRESSURE_CURVES.length[1]; j++) {
                if (values[j] != PRESSURE_CURVES[i,j]) {
                    match = false;
                    break;
                }
            }

            if (match) {
                scale.set_value (i);
                break;
            }
        }
    }

    private void build_pressure_slider (string label, string schema_key) {
        var scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 6, 1);
        scale.draw_value = false;
        scale.has_origin = false;
        scale.round_digits = 0;
        scale.add_mark (0, Gtk.PositionType.BOTTOM, _("Soft"));
        scale.add_mark (6, Gtk.PositionType.BOTTOM, _("Firm"));

        set_pressure_scale_value_from_settings (scale, schema_key);

        scale.value_changed.connect (() => {
            on_pressure_value_changed (scale, schema_key);
        });

        stylus_grid.attach (new Widgets.SettingLabel (label), 0, last_grid_y_pos);
        stylus_grid.attach (scale, 1, last_grid_y_pos);
        last_grid_y_pos++;
    }

    public void set_device (Backend.WacomTool dev) {
        stylus_grid.@foreach ((widget) => {
            widget.destroy ();
        });

        device = dev;
        settings = device.get_settings ();

        if (device.has_pressure_detection && device.has_eraser) {
            build_pressure_slider (_("Eraser Pressure Feel:"), "eraser-pressure-curve");
        }

        switch (device.num_buttons) {
            case 1:
                build_button_settings (_("Button Action:"), "button-action");
                break;
            case 2:
                build_button_settings (_("Top Button Action:"), "secondary-button-action");
                build_button_settings (_("Bottom Button Action:"), "button-action");
                break;
            case 3:
                build_button_settings (_("Top Button Action:"), "secondary-button-action");
                build_button_settings (_("Middle Button Action:"), "button-action");
                build_button_settings (_("Bottom Button Action:"), "tertiary-button-action");
                break;
            default:
                break;
        }

        if (device.has_pressure_detection) {
            build_pressure_slider (_("Tip Pressure Feel:"), "pressure-curve");
        }


        var test_button = new Gtk.Button.with_label (_("Test Tablet Settings"));
        var test_popover = new Gtk.Popover (test_button);
        test_popover.vexpand = true;
        test_popover.hexpand = true;
        test_popover.position = Gtk.PositionType.BOTTOM;

        var test_area = new Widgets.DrawingArea ();
        test_area.hexpand = true;
        test_area.vexpand = true;

        test_popover.add (test_area);

        test_button.clicked.connect (() => {
            test_area.clear ();
            test_popover.show_all ();
        });

        stylus_grid.attach (test_button, 0, last_grid_y_pos, 2, 1);

        show_all ();

        visible_child_name = "stylus";
    }
}
