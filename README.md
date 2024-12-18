# Wacom Settings
[![Translation status](https://l10n.elementary.io/widgets/switchboard/-/plug-wacom/svg-badge.svg)](https://l10n.elementary.io/engage/switchboard/?utm_source=widget)

![screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libadwaita-1-dev
* libswitchboard-3-dev
* libgranite-7-dev
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

    ninja install

To test Wacom plug without a tablet or pen use [hid-replay](https://github.com/hidutils/hid-replay/). The `hid-replay` repository releases page contains prebuilt binaries.
Remember to also clone [wacom-recordings](https://github.com/whot/wacom-recordings).
```
sudo hid-replay wacom-recordings/Wacom\ Intuos\ Pro\ M/pen.pen-light-horizontal.hid
```
