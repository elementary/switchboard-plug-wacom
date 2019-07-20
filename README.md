# Switchboard Wacom Plug

This is a WIP plug for [elementary Switchboard](https://github.com/elementary/switchboard) to configure settings for Wacom tablets.

## Building and Installation

You'll need the following dependencies:

* libswitchboard-2.0-dev
* libgranite-dev
* libwacom-dev
* libgudev-1.0-dev
* libx11-dev
* libxi-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
