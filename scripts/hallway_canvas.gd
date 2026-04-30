extends Control

# One-point perspective constants (fractions of node size)
const VP_X  := 0.50
const VP_Y  := 0.30
const VP_HW := 0.13   # tunnel half-width at vanishing point
const VP_HH := 0.09   # tunnel half-height at vanishing point

var _t   := 0.0
var _wks := []   # [{col, fx, fy, sc, po}]

func setup(companions: Array) -> void:
	_wks.clear()
	# Player — gold, centre foreground
	_wks.append({"col": Color(0.92, 0.78, 0.22), "fx": 0.50, "fy": 0.88, "sc": 1.0, "po": 0.0})
	for i in companions.size():
		var c   = companions[i]
		var tc  = CompanionSystem.type_color(c.get("type", "fighter"))
		var sgn := 1.0 if i % 2 == 0 else -1.0
		_wks.append({
			"col": Color(tc.r, tc.g, tc.b, 0.92),
			"fx":  0.50 + sgn * 0.16,
			"fy":  0.72,
			"sc":  0.68,
			"po":  TAU / 3.0 * float(i + 1)
		})

func _process(delta: float) -> void:
	_t = fmod(_t + delta * 5.5, TAU)
	queue_redraw()

func _draw() -> void:
	var W := size.x
	var H := size.y
	if W < 10.0 or H < 10.0:
		return
	_draw_hallway(W, H)
	for wd in _wks:
		_draw_fig(wd, W, H)

# ── HALLWAY ────────────────────────────────────────────────────────────────
func _draw_hallway(W: float, H: float) -> void:
	var vpx := W * VP_X
	var vpy := H * VP_Y
	var vhw := W * VP_HW
	var vhh := H * VP_HH

	# Background fill
	draw_rect(Rect2(0, 0, W, H), Color(0.022, 0.010, 0.048))

	# Ceiling (darkest — overhead stone)
	draw_polygon(
		PackedVector2Array([
			Vector2(0, 0),      Vector2(W, 0),
			Vector2(vpx + vhw, vpy - vhh), Vector2(vpx - vhw, vpy - vhh)
		]),
		PackedColorArray([
			Color(0.010, 0.005, 0.025), Color(0.010, 0.005, 0.025),
			Color(0.022, 0.011, 0.048), Color(0.022, 0.011, 0.048)
		])
	)

	# Left wall
	draw_polygon(
		PackedVector2Array([
			Vector2(0, 0),          Vector2(0, H),
			Vector2(vpx - vhw, vpy), Vector2(vpx - vhw, vpy - vhh)
		]),
		PackedColorArray([
			Color(0.025, 0.012, 0.055), Color(0.040, 0.020, 0.080),
			Color(0.048, 0.024, 0.095), Color(0.030, 0.015, 0.062)
		])
	)

	# Right wall
	draw_polygon(
		PackedVector2Array([
			Vector2(W, 0),          Vector2(W, H),
			Vector2(vpx + vhw, vpy), Vector2(vpx + vhw, vpy - vhh)
		]),
		PackedColorArray([
			Color(0.025, 0.012, 0.055), Color(0.040, 0.020, 0.080),
			Color(0.048, 0.024, 0.095), Color(0.030, 0.015, 0.062)
		])
	)

	# Floor (slightly warmer/lighter than walls)
	draw_polygon(
		PackedVector2Array([
			Vector2(0, H),      Vector2(W, H),
			Vector2(vpx + vhw, vpy), Vector2(vpx - vhw, vpy)
		]),
		PackedColorArray([
			Color(0.060, 0.030, 0.095), Color(0.060, 0.030, 0.095),
			Color(0.032, 0.016, 0.062), Color(0.032, 0.016, 0.062)
		])
	)

	# Far tunnel opening (the glow at the end of the corridor)
	draw_rect(Rect2(vpx - vhw, vpy - vhh, vhw * 2.0, vhh), Color(0.055, 0.028, 0.095))
	for i in range(6):
		var a := 0.06 - i * 0.009
		var r := vhw * (0.45 + i * 0.90)
		draw_circle(Vector2(vpx, vpy - vhh * 0.35), r, Color(0.55, 0.32, 0.10, a))

	# Floor perspective grid lines (receding to VP)
	for i in range(1, 8):
		var t  := float(i) / 8.0
		var ly := lerp(H, vpy, t)
		var xl := lerp(0.0, vpx - vhw, t)
		var xr := lerp(W, vpx + vhw, t)
		var a  := lerp(0.20, 0.03, t)
		draw_line(Vector2(xl, ly), Vector2(xr, ly), Color(0.20, 0.10, 0.32, a), 1.0)

	# Convergence lines — floor edges and ceiling edges
	draw_line(Vector2(0, H),   Vector2(vpx - vhw, vpy), Color(0.25, 0.12, 0.40, 0.40), 1.5)
	draw_line(Vector2(W, H),   Vector2(vpx + vhw, vpy), Color(0.25, 0.12, 0.40, 0.40), 1.5)
	draw_line(Vector2(0, 0),   Vector2(vpx - vhw, vpy - vhh), Color(0.14, 0.07, 0.25, 0.22), 1.0)
	draw_line(Vector2(W, 0),   Vector2(vpx + vhw, vpy - vhh), Color(0.14, 0.07, 0.25, 0.22), 1.0)

	# Wall vertical texture lines
	for i in range(1, 5):
		var t  := float(i) / 5.0
		var lx := lerp(0.0, vpx - vhw, t)
		var rx := lerp(W,   vpx + vhw, t)
		var yb_l := lerp(H, vpy,       t)
		var yt_l := lerp(0.0, vpy - vhh, t)
		var yb_r := lerp(H, vpy,       t)
		var yt_r := lerp(0.0, vpy - vhh, t)
		draw_line(Vector2(lx, yb_l), Vector2(lx, yt_l), Color(0.08, 0.04, 0.16, 0.14), 1.0)
		draw_line(Vector2(rx, yb_r), Vector2(rx, yt_r), Color(0.08, 0.04, 0.16, 0.14), 1.0)

	# Torches
	_draw_torch(W, H, vpx, vpy, vhw, vhh, false)
	_draw_torch(W, H, vpx, vpy, vhw, vhh, true)

func _draw_torch(W: float, H: float, vpx: float, vpy: float,
				 vhw: float, vhh: float, right: bool) -> void:
	var t      := 0.26
	var near_x := 0.0 if not right else W
	var far_x  := (vpx - vhw) if not right else (vpx + vhw)
	var wx     := lerp(near_x, far_x, t)
	var wy_b   := lerp(H,   vpy,       t)
	var wy_t   := lerp(0.0, vpy - vhh, t)
	var wy     := lerp(wy_b, wy_t, 0.52)

	var stick  := W * 0.038 * (1.0 - t * 0.5)
	var tip_x  := wx + (stick if not right else -stick)
	var tip_y  := wy - stick * 0.3

	# Bracket
	draw_line(Vector2(wx, wy), Vector2(tip_x, wy), Color(0.45, 0.28, 0.12), 2.5)
	draw_line(Vector2(tip_x, wy), Vector2(tip_x, wy - stick * 0.5), Color(0.45, 0.28, 0.12), 2.0)

	# Flicker animation
	var flicker := 0.82 + sin(_t * 3.8 + (1.4 if right else 0.0)) * 0.18
	var gr      := W * 0.060 * flicker * (1.0 - t * 0.35)

	# Glow rings (warm fire)
	draw_circle(Vector2(tip_x, tip_y), gr * 4.0, Color(0.65, 0.35, 0.08, 0.04))
	draw_circle(Vector2(tip_x, tip_y), gr * 2.5, Color(0.80, 0.46, 0.12, 0.09))
	draw_circle(Vector2(tip_x, tip_y), gr * 1.4, Color(0.95, 0.60, 0.20, 0.18))
	draw_circle(Vector2(tip_x, tip_y), gr * 0.65, Color(1.00, 0.80, 0.38, 0.50))
	draw_circle(Vector2(tip_x, tip_y), gr * 0.28, Color(1.00, 0.95, 0.80, 0.88))

	# Flame tip flicker
	var ftip := Vector2(tip_x + sin(_t * 4.3) * gr * 0.2, tip_y - gr * 0.4)
	draw_circle(ftip, gr * 0.18, Color(1.0, 0.98, 0.7, 0.75))

	# Wall wash
	draw_circle(Vector2(wx, wy), gr * 5.5, Color(0.55, 0.30, 0.06, 0.05 * flicker))

# ── FIGURE ─────────────────────────────────────────────────────────────────
func _draw_fig(wd: Dictionary, W: float, H: float) -> void:
	var ph  := _t + float(wd["po"])
	var col := wd["col"] as Color
	var sc  := float(wd["sc"])
	var fx  := float(wd["fx"])
	var fy  := float(wd["fy"])

	var cx   := W * fx
	var base := H * fy

	# Perspective scale: figures further up the floor appear smaller
	var persp := clamp((fy - VP_Y) / (1.0 - VP_Y), 0.25, 1.0)
	var fh    := H * 0.30 * sc * persp
	var hr    := fh * 0.19
	var ll    := fh * 0.54
	var al    := fh * 0.40
	var lw    := maxf(1.5, 2.8 * sc * persp)

	var bob := sin(ph * 2.0) * fh * 0.030
	var hip := Vector2(cx, base + bob)
	var sho := Vector2(cx, base - fh + bob)
	var hd  := Vector2(cx, base - fh - hr * 1.15 + bob)

	var lsw := sin(ph) * 0.54
	var asw := sin(ph + PI) * 0.36

	# Ground shadow
	draw_circle(Vector2(cx, base + lw), ll * 0.20, Color(0.0, 0.0, 0.0, 0.35 * persp))

	# Subtle glow so figure pops off dark background
	draw_line(hip, sho, Color(col.r, col.g, col.b, 0.10), lw * 4.0)
	draw_circle(hd, hr * 1.8, Color(col.r, col.g, col.b, 0.07))

	# Legs
	draw_line(hip, hip + Vector2(sin(lsw) * ll,  cos(lsw)  * ll * 0.84), col.darkened(0.22), lw)
	draw_line(hip, hip + Vector2(sin(-lsw) * ll, cos(-lsw) * ll * 0.84), col.darkened(0.22), lw)

	# Torso
	draw_line(hip, sho, col, lw * 1.45)

	# Arms
	draw_line(sho, sho + Vector2(sin(asw) * al,  cos(asw)  * al * 0.48), col.lightened(0.08), lw * 0.88)
	draw_line(sho, sho + Vector2(sin(-asw) * al, cos(-asw) * al * 0.48), col.lightened(0.08), lw * 0.88)

	# Head
	draw_circle(hd, hr, col)
	draw_circle(hd + Vector2(hr * 0.30, hr * 0.05), hr * 0.24, col.darkened(0.62))
