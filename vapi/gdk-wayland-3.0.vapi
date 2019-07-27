[CCode (cheader_filename = "gdk/gdkwayland.h")]
namespace GdkWayland
{
    [CCode (type_id = "gdk_wayland_device_get_type ()")]
    public class Device : Gdk.Device {
        public unowned string? get_node_path ();
    }
}

