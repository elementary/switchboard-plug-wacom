[CCode (gir_namespace = "xi", gir_version = "2.0", cprefix = "", lower_case_cprefix = "", cheader_filename = "X11/extensions/XInput2.h")]
namespace XI2 {
    [CCode (cname = "XIGetProperty")]
    public static int get_property (X.Display display, int deviceid, X.Atom property, long long_offset, long long_length, bool delete, X.Atom req_type, out X.Atom actual_type_return, out int actual_format_return, out ulong nitems_return, out ulong bytes_after_return, [CCode (type = "unsigned char **")] out void* prop_return);
}

