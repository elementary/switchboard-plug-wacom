/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2019-2024 elementary, Inc. (https://elementary.io)
 */

public class Wacom.Plug : Switchboard.Plug {
    private MainPage main_page;

    public Plug () {
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");

        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("input/pointing/stylus", "general");
        // deprecated
        settings.set ("input/wacom", "general");

        Object (
            category: Category.HARDWARE,
            code_name: "pantheon-wacom",
            display_name: _("Wacom"),
            description: _("Configure Wacom tablet"),
            icon: "input-tablet",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_page == null) {
            main_page = new MainPage ();
        }

        return main_page;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    /* 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior") */
    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Wacom plug");
    return new Wacom.Plug ();
}
