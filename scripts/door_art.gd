class_name DoorPanel
extends Control

signal door_pressed

const SCHEMES = [
	{	# Amber / Fire
		"stone":  Color(0.20, 0.16, 0.11),
		"wood":   Color(0.28, 0.14, 0.05),
		"panel":  Color(0.20, 0.10, 0.03),
		"accent": Color(0.78, 0.50, 0.12),
		"glow":   Color(0.95, 0.55, 0.15),
		"light":  Color(1.00, 0.80, 0.40),
	},
	{	# Violet / Arcane
		"stone":  Color(0.15, 0.11, 0.20),
		"wood":   Color(0.20, 0.08, 0.26),
		"panel":  Color(0.13, 0.05, 0.18),
		"accent": Color(0.68, 0.22, 0.82),
		"glow":   Color(0.75, 0.20, 0.95),
		"light":  Color(0.85, 0.55, 1.00),
	},
	{	# Ice / Blue
		"stone":  Color(0.11, 0.15, 0.20),
		"wood":   Color(0.06, 0.15, 0.30),
		"panel":  Color(0.04, 0.10, 0.22),
		"accent": Color(0.22, 0.58, 0.88),
		"glow":   Color(0.25, 0.65, 1.00),
		"light":  Color(0.65, 0.88, 1.00),
	},
]

const DOOR_NAMES = [
	"THE ASHEN GATE", "THE VOID PORTAL", "THE EMBER DOOR",
	"THE IRON THRESHOLD", "THE BONE PASSAGE", "THE GOLDEN ARCH",
	"THE SHADOW WAY", "THE FROST GATE", "THE CRIMSON DOOR",
	"THE OBSIDIAN ARCH", "THE SILVER PATH", "THE CURSED WAY",
	"THE PALE GATE", "THE WAILING DOOR", "THE SILENT GATE",
	"THE FORGOTTEN ARCH", "THE RUSTED GATE", "THE BLOOD DOOR",
	"THE MOONLIT ARCH", "THE ANCIENT PASSAGE", "THE BROKEN SEAL",
	"THE IRON VEIL", "THE DARK PASSAGE", "THE GILDED GATE",
	"THE HOLLOW ARCH", "THE BURNING DOOR", "THE WHISPERING GATE",
	"THE CRACKED SEAL", "THE SUNKEN DOOR", "THE LOST WAY",
]

var door_index: int = 0
var _highlighted: bool = false
var _open_btn: Button
var _name_label: Label

func setup(idx: int, dname: String, hint: String = "") -> void:
	door_index = idx % SCHEMES.size()
	if _name_label:
		_name_label.text = dname
		_name_label.add_theme_color_override("font_color", SCHEMES[door_index]["accent"])
	if hint != "":
		var hl := Label.new()
		hl.text = hint
		hl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		hl.offset_top    = -56
		hl.offset_bottom = -42
		hl.offset_left   = 4
		hl.offset_right  = -4
		hl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hl.add_theme_font_size_override("font_size", 7)
		hl.add_theme_color_override("font_color", Color(SCHEMES[door_index]["light"].r, SCHEMES[door_index]["light"].g, SCHEMES[door_index]["light"].b, 0.72))
		add_child(hl)
	queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(110, 270)
	mouse_filter = Control.MOUSE_FILTER_PASS

	_open_btn = Button.new()
	_open_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_open_btn.flat = true
	_open_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_open_btn.pressed.connect(func(): door_pressed.emit())
	_open_btn.mouse_entered.connect(func(): _highlighted = true; queue_redraw())
	_open_btn.mouse_exited.connect(func(): _highlighted = false; queue_redraw())
	add_child(_open_btn)

	_name_label = Label.new()
	_name_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_name_label.offset_top   = -42
	_name_label.offset_left  = 2
	_name_label.offset_right = -2
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.add_theme_font_size_override("font_size", 9)
	_name_label.add_theme_color_override("font_color", SCHEMES[door_index]["accent"])
	add_child(_name_label)

func disable() -> void:
	if _open_btn:
		_open_btn.disabled = true
	queue_redraw()

func _draw() -> void:
	if size.x < 10 or size.y < 10:
		return

	var s   = SCHEMES[door_index]
	var w   = size.x
	var h   = size.y
	var dx  = 5.0
	var bot = h - 44.0      # bottom of door (name label sits below)

	# Hover glow rings
	if _highlighted:
		for i in range(6, 0, -1):
			var alpha = 0.04 * (7 - i)
			draw_rect(Rect2(-i * 3, -i * 3, w + i * 6, h + i * 6),
					  Color(s["glow"].r, s["glow"].g, s["glow"].b, alpha))

	# Stone surround
	var sh_y = h * 0.22
	draw_rect(Rect2(0, sh_y, w, bot - sh_y), s["stone"])

	# Full door shape: pointed gothic arch + body
	var arch_pk = h * 0.02
	var door_poly := PackedVector2Array([
		Vector2(dx,     bot),
		Vector2(dx,     sh_y),
		Vector2(w * 0.5, arch_pk),
		Vector2(w - dx, sh_y),
		Vector2(w - dx, bot),
	])
	draw_colored_polygon(door_poly, s["wood"] as Color)
	draw_polyline(door_poly, s["accent"], 1.5, true)
	draw_line(Vector2(dx, bot), Vector2(w - dx, bot), s["accent"], 1.5)

	# Panel dimensions
	var px  = dx + 8.0
	var pw  = w - dx * 2.0 - 16.0
	var mid = sh_y + (bot - sh_y) * 0.50

	# Upper panel (arch region has a small inset)
	var up_top = sh_y + 14.0
	var up_bot = mid - 6.0
	draw_rect(Rect2(px, up_top, pw, up_bot - up_top), s["panel"])
	draw_rect(Rect2(px, up_top, pw, up_bot - up_top), s["accent"], false, 1.2)
	_cross(px, up_top, pw, up_bot - up_top, s["accent"])

	# Middle rail
	draw_line(Vector2(dx + 4, mid), Vector2(w - dx - 4, mid), s["accent"], 2.0)

	# Lower panel
	var lo_top = mid + 6.0
	var lo_bot = bot - 46.0
	if lo_bot - lo_top > 14:
		draw_rect(Rect2(px, lo_top, pw, lo_bot - lo_top), s["panel"])
		draw_rect(Rect2(px, lo_top, pw, lo_bot - lo_top), s["accent"], false, 1.2)
		_cross(px, lo_top, pw, lo_bot - lo_top, s["accent"])

	# Hinges on left
	for pct in [0.30, 0.68]:
		var hy = sh_y + (bot - sh_y) * pct
		draw_rect(Rect2(dx - 2, hy - 7, 10, 14), s["accent"])
		draw_rect(Rect2(dx - 2, hy - 7, 10, 14), s["stone"], false, 1.0)

	# Doorknob on right
	var kx = w - dx - 10.0
	var ky = mid + 16.0
	draw_circle(Vector2(kx, ky), 7.0, s["accent"])
	draw_circle(Vector2(kx, ky), 7.0, s["stone"], false, 1.5)
	draw_circle(Vector2(kx - 2.0, ky - 2.0), 3.0, s["light"])

	# Light crack from door edge
	var lca = 0.7 if _highlighted else 0.3
	draw_line(Vector2(dx + 1.0, sh_y + 22.0),
			  Vector2(dx + 1.0, bot - 50.0),
			  Color(s["light"].r, s["light"].g, s["light"].b, lca), 1.5)

	# Arch gem sparkle
	var ga = 0.95 if _highlighted else 0.60
	var gp = Vector2(w * 0.5, arch_pk + 8.0)
	draw_circle(gp, 4.0, Color(s["glow"].r, s["glow"].g, s["glow"].b, ga))
	draw_circle(gp, 8.0, Color(s["glow"].r, s["glow"].g, s["glow"].b, 0.18))

func _cross(px: float, py: float, pw: float, ph: float, accent: Color) -> void:
	var dim_c = Color(accent.r, accent.g, accent.b, 0.35)
	draw_line(Vector2(px + 4, py + ph * 0.5), Vector2(px + pw - 4, py + ph * 0.5), dim_c, 1.0)
	draw_line(Vector2(px + pw * 0.5, py + 4), Vector2(px + pw * 0.5, py + ph - 4), dim_c, 1.0)
