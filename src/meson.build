plug_files = files(
    'Backend/Device.vala',
    'Backend/DeviceManager.vala',
    'Backend/DeviceManagerWayland.vala',
    'Backend/DeviceManagerX11.vala',
    'Backend/WacomTool.vala',
    'Backend/WacomToolMap.vala',
    'Views/StylusView.vala',
    'Views/TabletView.vala',
    'Widgets/DrawingArea.vala',
    'MainPage.vala',
    'Plug.vala'
)

switchboard_dep = dependency('switchboard-3')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    plug_files,
    config_file,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7'),
        dependency('gtk4'),
        dependency('libwacom'),
        dependency('gudev-1.0'),
        # dependency('gdk-x11-3.0'),
        dependency('gdk-wayland-3.0'),
        dependency('x11'),
        dependency('xi'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'hardware')
)

