/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.StylusView : Gtk.Box {
    private const int32[,] PRESSURE_CURVES = {
        { 0, 75, 25, 100 }, /* soft */
        { 0, 50, 50, 100 },
        { 0, 25, 75, 100 },
        { 0, 0, 100, 100 }, /* neutral */
        { 25, 0, 100, 75 },
        { 50, 0, 100, 50 },
        { 75, 0, 100, 25 }  /* firm */
    };

    private static Gtk.SizeGroup label_sizegroup;
    private static Wacom.DeviceDatabase wacom_db;

    private GLib.Settings settings;
    private Gtk.Box stylus_box;

    static construct {
        label_sizegroup = new Gtk.SizeGroup (HORIZONTAL);
        wacom_db = new Wacom.DeviceDatabase ();
    }

    construct {
        stylus_box = new Gtk.Box (VERTICAL, 12);

        add (stylus_box);
    }

    public void set_device (Backend.WacomTool wacom_tool) {
        stylus_box.@foreach ((widget) => {
            widget.destroy ();
        });

        unowned var stylus = wacom_db.get_stylus_for_id ((int) wacom_tool.id);

        var header_label = new Granite.HeaderLabel (stylus.get_name ()) {
            hexpand = true
        };

        var test_button = new Gtk.Button.with_label (_("Test Settings"));

        var test_area = new Widgets.DrawingArea () {
            hexpand = true,
            vexpand = true
        };

        var frame = new Gtk.Frame (null) {
            child = test_area,
            margin_start = 10,
            margin_end = 10
        };
        frame.show_all ();

        var test_dialog = new Granite.Dialog () {
            default_width = 500,
            default_height = 400,
            modal = true,
            transient_for = ((Gtk.Application) Application.get_default ()).active_window
        };
        test_dialog.get_content_area ().add (frame);
        test_dialog.add_button ("Close", Gtk.ResponseType.CLOSE);

        var header_box = new Gtk.Box (HORIZONTAL, 12);
        header_box.add (header_label);
        header_box.add (test_button);

        stylus_box.add (header_box);

        settings = new Settings.with_path (
            "org.gnome.desktop.peripherals.tablet.stylus",
            wacom_tool.settings_path
        );

        var has_pressure_detection = Wacom.AxisTypeFlags.PRESSURE in stylus.get_axes ();

        if (has_pressure_detection && stylus.has_eraser ()) {
            stylus_box.add (pressure_setting (_("Eraser Pressure Feel"), "eraser-pressure-curve"));
        }

        switch (stylus.get_num_buttons ()) {
            case 1:
                stylus_box.add (button_setting (_("Button Action"), "button-action"));
                break;
            case 2:
                stylus_box.add (button_setting (_("Top Button Action"), "secondary-button-action"));
                stylus_box.add (button_setting (_("Bottom Button Action"), "button-action"));
                break;
            case 3:
                stylus_box.add (button_setting (_("Top Button Action"), "secondary-button-action"));
                stylus_box.add (button_setting (_("Middle Button Action"), "button-action"));
                stylus_box.add (button_setting (_("Bottom Button Action"), "tertiary-button-action"));
                break;
        }

        if (has_pressure_detection) {
            stylus_box.add (pressure_setting (_("Tip Pressure Feel"), "pressure-curve"));
        }

        show_all ();

        test_button.clicked.connect (() => {
            test_area.clear ();
            test_dialog.present ();
        });

        test_dialog.response.connect (() => test_dialog.hide ());
    }

    private Gtk.Box button_setting (string label, string schema_key) {
        var button_combo = new Gtk.ComboBoxText () {
            hexpand = true
        };
        button_combo.append ("default", _("Default"));
        button_combo.append ("middle", _("Middle Mouse Button Click"));
        button_combo.append ("right", _("Right Mouse Button Click"));
        button_combo.append ("back", _("Back"));
        button_combo.append ("forward", _("Forward"));

        var setting_label = new Gtk.Label (label) {
            mnemonic_widget = button_combo,
            xalign = 0
        };

        label_sizegroup.add_widget (setting_label);

        var box = new Gtk.Box (HORIZONTAL, 12);
        box.add (setting_label);
        box.add (button_combo);

        settings.bind (schema_key, button_combo, "active-id", SettingsBindFlags.DEFAULT);

        return box;
    }

    private Gtk.Box pressure_setting (string label, string schema_key) {
        var scale = new Gtk.Scale.with_range (HORIZONTAL, 0, 6, 1) {
            draw_value = false,
            has_origin = false,
            hexpand = true,
            round_digits = 0
        };
        scale.add_mark (0, BOTTOM, _("Soft"));
        scale.add_mark (6, BOTTOM, _("Firm"));

        set_pressure_scale_value_from_settings (scale, schema_key);

        scale.value_changed.connect (() => {
            on_pressure_value_changed ((int) scale.get_value (), schema_key);
        });

        var setting_label = new Gtk.Label (label) {
            mnemonic_widget = scale,
            xalign = 0
        };

        label_sizegroup.add_widget (setting_label);

        var box = new Gtk.Box (HORIZONTAL, 12);
        box.add (setting_label);
        box.add (scale);

        return (box);
    }

    private void on_pressure_value_changed (int new_value, string schema_key) {
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
}
