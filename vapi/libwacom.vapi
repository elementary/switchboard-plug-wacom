namespace Wacom {
	[CCode (cheader_filename = "libwacom/libwacom.h", cname = "enum WacomErrorCode", cprefix = "WERROR_", has_type_id = false)]
	public enum ErrorCode {
		NONE,
		BAD_ALLOC,
		INVALID_PATH,
		INVALID_DB,
		BAD_ACCESS,
		UNKNOWN_MODEL
	}

	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WBUSTYPE_", has_type_id = false)]
	public enum BusType {
		UNKNOWN,
		USB,
		SERIAL,
		BLUETOOTH,
		I2C
	}

	[Flags]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WACOM_DEVICE_INTEGRATED_", has_type_id = false)]
	public enum IntegrationFlags {
		NONE,
		DISPLAY,
		SYSTEM
	}

	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WCLASS_", has_type_id = false)]
	public enum Class {
		UNKNOWN,
		INTUOS3,
		INTUOS4,
		INTUOS5,
		CINTIQ,
		BAMBOO,
		GRAPHIRE,
		ISDV4,
		INTUOS,
		INTUOS2,
		PEN_DISPLAYS,
		REMOTE
	}

	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WSTYLUS_", has_type_id = false)]
	public enum StylusType {
		UNKNOWN,
		GENERAL,
		INKING,
		AIRBRUSH,
		CLASSIC,
		MARKER,
		STROKE,
		PUCK,
		3D
	}

	[Flags]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WACOM_BUTTON_", has_type_id = false)]
	public enum ButtonFlags {
		NONE,
		POSITION_LEFT,
		POSITION_RIGHT,
		POSITION_TOP,
		POSITION_BOTTOM,
		RING_MODESWITCH,
		RING2_MODESWITCH,
		TOUCHSTRIP_MODESWITCH,
		TOUCHSTRIP2_MODESWITCH,
		OLED,
		MODESWITCH,
		DIRECTION,
		RINGS_MODESWITCH,
		TOUCHSTRIPS_MODESWITCH
	}

	[Flags]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WACOM_AXIS_TYPE_", has_type_id = false)]
	public enum AxisTypeFlags {
		NONE,
		TILT,
		ROTATION_Z,
		DISTANCE,
		PRESSURE,
		SLIDER
	}

	[Flags]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WFALLBACK_", has_type_id = false)]
	public enum FallbackFlags {
		NONE,
		GENERIC
	}

	[Flags]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WCOMPARE_", has_type_id = false)]
	public enum CompareFlags {
		NORMAL,
		MATCHES
	}

	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "WACOM_STATUS_LED_", has_type_id = false)]
	public enum StatusLEDs {
		UNAVAILABLE,
		RING,
		RING2,
		TOUCHSTRIP,
		TOUCHSTRIP2
	}

	[Compact]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "libwacom_", free_function = "libwacom_destroy")]
	public class Device {
		public int compare (Wacom.Device b, Wacom.CompareFlags flags = Wacom.CompareFlags.NORMAL);
		public Wacom.Class get_class ();
		public unowned string get_name ();
		public unowned string get_layout_filename ();
		public int get_vendor_id ();
		public int get_product_id ();
		public unowned string get_match ();
		[CCode (array_null_terminated = true, array_length = false)]
		public (unowned Wacom.Match)[] get_matches ();
		public unowned Wacom.Match? get_paired_device ();
		public int get_width ();
		public int get_height ();
		[CCode (cname = "_vala_libwacom_has_stylus")]
		public bool has_stylus () {
			return _has_stylus () != 0;
		}
		[CCode (cname = "libwacom_has_stylus")]
		private int _has_stylus ();
		[CCode (cname = "_vala_libwacom_has_touch")]
		public bool has_touch () {
			return _has_touch () != 0;
		}
		[CCode (cname = "libwacom_has_touch")]
		private int _has_touch ();
		public int get_num_buttons ();
		public int[] get_supported_styli ();
		[CCode (cname = "_vala_libwacom_has_ring")]
		public bool has_ring () {
			return _has_ring () != 0;
		}
		[CCode (cname = "libwacom_has_ring")]
		private int _has_ring ();
		[CCode (cname = "_vala_libwacom_has_ring2")]
		public bool has_ring2 () {
			return _has_ring2 () != 0;
		}
		[CCode (cname = "libwacom_has_ring2")]
		private int _has_ring2 ();
		[CCode (cname = "_vala_libwacom_has_touchswitch")]
		public bool has_touchswitch () {
			return _has_touchswitch () != 0;
		}
		[CCode (cname = "libwacom_has_touchswitch")]
		private int _has_touchswitch ();
		public int get_ring_num_modes ();
		public int get_ring2_num_modes ();
		public int get_num_strips ();
		public int get_strips_num_modes ();
		public Wacom.StatusLEDs[] get_status_leds ();
		public int get_button_led_group (char button);
		[CCode (cname = "_vala_libwacom_is_reversible")]
		public bool is_reversible () {
			return _is_reversible () != 0;
		}
		[CCode (cname = "libwacom_is_reversible")]
		private int _is_reversible ();
		public Wacom.IntegrationFlags get_integration_flags ();
		public Wacom.BusType get_bustype ();
		public Wacom.ButtonFlags get_button_flag (char button);
		public int get_button_evdev_code (char button);
		[CCode (cname = "libwacom_print_device_description", instance_pos = 1)]
		public void print_description (int fd);
	}

	[Compact]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "libwacom_match_", free_function = "")]
	public class Match {
		public unowned string get_name ();
		public Wacom.BusType get_bustype ();
		public uint32 get_product_id ();
		public uint32 get_vendor_id ();
		public unowned string get_match_string ();
	}

	[Compact]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "libwacom_stylus_", free_function = "")]
	public class Stylus {
		[CCode (cname = "WACOM_STYLUS_FALLBACK_ID")]
		public const int STYLUS_FALLBACK_ID;
		[CCode (cname = "WACOM_ERASER_FALLBACK_ID")]
		public const int ERASER_FALLBACK_ID;
		public int get_id ();
		public unowned string get_name ();
		public int get_num_buttons ();
		[CCode (cname = "_vala_libwacom_stylus_has_eraser")]
		public bool has_eraser () {
			return _has_eraser () != 0;
		}
		[CCode (cname = "libwacom_stylus_has_eraser")]
		private int _has_eraser ();
		[CCode (cname = "_vala_libwacom_stylus_is_eraser")]
		public bool is_eraser () {
			return _is_eraser () != 0;
		}
		[CCode (cname = "libwacom_stylus_is_eraser")]
		private int _is_eraser ();
		[CCode (cname = "_vala_libwacom_stylus_has_lens")]
		public bool has_lens () {
			return _has_lens () != 0;
		}
		[CCode (cname = "libwacom_stylus_has_lens")]
		private int _has_lens ();
		[CCode (cname = "_vala_libwacom_stylus_has_wheel")]
		public bool has_wheel () {
			return _has_wheel () != 0;
		}
		[CCode (cname = "libwacom_stylus_has_wheel")]
		private int _has_wheel ();
		public Wacom.AxisTypeFlags get_axes ();
		public Wacom.StylusType get_type ();
		[CCode (cname = "libwacom_print_stylus_description", instance_pos = 1)]
		public void print_description (int fd);
	}

	[Compact]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "libwacom_error_", free_function = "libwacom_error_free", free_function_address_of = true)]
	public class Error {
		public Error ();
		public Wacom.ErrorCode get_code ();
		public unowned string get_message ();
	}

	[Compact]
	[CCode (cheader_filename = "libwacom/libwacom.h", cprefix = "libwacom_database_", free_function = "libwacom_database_destroy")]
	public class DeviceDatabase {
		public DeviceDatabase ();
		public DeviceDatabase.for_path (string datadir);
		[CCode (cname ="libwacom_new_from_path")]
		public Wacom.Device? get_device_from_path (string path, Wacom.FallbackFlags fallback = Wacom.FallbackFlags.NONE, Wacom.Error? error = null);
		public Wacom.Device? get_device_from_usbid (int vendor_id, int product_id, Wacom.Error? error = null);
		public Wacom.Device? get_device_from_name (string name, Wacom.Error? error = null);
		[CCode (cname = "libwacom_list_devices_from_database", array_null_terminated = true, array_length = false)]
		public (unowned Wacom.Device)[] list_devices (Wacom.Error? error = null);
		[CCode (cname = "libwacom_stylus_get_for_id")]
		public unowned Wacom.Stylus get_stylus_for_id (int id);
	}
}
