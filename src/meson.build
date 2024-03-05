plug_files = files(
    'Backend/Device.vala',
    'Backend/DeviceManager.vala',
    'Backend/WacomDevice.vala',
    'Backend/WacomTool.vala',
    'Backend/WacomToolMap.vala',
    'Views/StylusView.vala',
    'Views/TabletView.vala',
    'Widgets/DrawingArea.vala',
    'MainPage.vala',
    'Plug.vala'
)

switchboard_dep = dependency('switchboard-2.0')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    plug_files,
    config_file,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libwacom'),
        dependency('gudev-1.0'),
        dependency('gdk-wayland-3.0'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'hardware')
)

