plug_files = files(
    'Backend/Device.vala',
    'Backend/DeviceManager.vala',
    'Backend/DeviceManagerWayland.vala',
    'Backend/DeviceManagerX11.vala',
    'Backend/WacomDevice.vala',
    'Views/StylusView.vala',
    'Views/TabletView.vala',
    'Plug.vala',
    'Utils.vala'
)

switchboard_dep = dependency('switchboard-2.0')

shared_module(
    meson.project_name(),
    plug_files,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libwacom'),
        dependency('gudev-1.0'),
        dependency('gdk-x11-3.0'),
        dependency('x11'),
        dependency('xi'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_dep.get_pkgconfig_variable('plugsdir'), 'hardware')
)

