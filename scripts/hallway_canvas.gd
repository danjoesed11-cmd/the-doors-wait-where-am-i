extends Control

const VP_X  = 0.50
const VP_Y  = 0.30
const VP_HW = 0.13
const VP_HH = 0.09

var _t              : float  = 0.0
var _wks            : Array  = []
var _player_weapon  : String = ""

func setup(companions: Array, weapons: Array = []) -> void:
	_player_weapon = weapons[0].get("weapon_type", "") if not weapons.is_empty() else ""
	_wks.clear()
	_wks.append({"col": Color(0.92, 0.78, 0.22), "fx": 0.50, "fy": 0.88, "sc": 1.0, "po": 0.0})
	for i in companions.size():
		var c   = companions[i]
		var tc  = CompanionSystem.type_color(c.get("type", "fighter"))
		var sgn : float = 1.0 if i % 2 == 0 else -1.0
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
	var W : float = size.x
	var H : float = size.y
	if W < 10.0 or H < 10.0:
		return
	_draw_hallway(W, H)
	for wd in _wks:
		_draw_fig(wd, W, H)

# ── HALLWAY ─────────────────────────────────────────────────────────────────
func _draw_hallway(W: float, H: float) -> void:
	var vpx : float = W * VP_X
	var vpy : float = H * VP_Y
	var vhw : float = W * VP_HW
	var vhh : float = H * VP_HH

	draw_rect(Rect2(0, 0, W, H), Color(0.022, 0.010, 0.048))

	# Ceiling
	draw_polygon(
		PackedVector2Array([
			Vector2(0, 0), Vector2(W, 0),
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
			Vector2(0, 0),           Vector2(0, H),
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
			Vector2(W, 0),           Vector2(W, H),
			Vector2(vpx + vhw, vpy), Vector2(vpx + vhw, vpy - vhh)
		]),
		PackedColorArray([
			Color(0.025, 0.012, 0.055), Color(0.040, 0.020, 0.080),
			Color(0.048, 0.024, 0.095), Color(0.030, 0.015, 0.062)
		])
	)

	# Floor
	draw_polygon(
		PackedVector2Array([
			Vector2(0, H),       Vector2(W, H),
			Vector2(vpx + vhw, vpy), Vector2(vpx - vhw, vpy)
		]),
		PackedColorArray([
			Color(0.060, 0.030, 0.095), Color(0.060, 0.030, 0.095),
			Color(0.032, 0.016, 0.062), Color(0.032, 0.016, 0.062)
		])
	)

	# Far end glow
	draw_rect(Rect2(vpx - vhw, vpy - vhh, vhw * 2.0, vhh), Color(0.055, 0.028, 0.095))
	for i in range(6):
		var a : float = 0.06 - float(i) * 0.009
		var r : float = vhw * (0.45 + float(i) * 0.90)
		draw_circle(Vector2(vpx, vpy - vhh * 0.35), r, Color(0.55, 0.32, 0.10, a))

	# Floor perspective lines
	for i in range(1, 8):
		var t  : float = float(i) / 8.0
		var ly : float = lerp(H, vpy, t)
		var xl : float = lerp(0.0, vpx - vhw, t)
		var xr : float = lerp(W, vpx + vhw, t)
		var a  : float = lerp(0.20, 0.03, t)
		draw_line(Vector2(xl, ly), Vector2(xr, ly), Color(0.20, 0.10, 0.32, a), 1.0)

	# Convergence lines
	draw_line(Vector2(0, H), Vector2(vpx - vhw, vpy),       Color(0.25, 0.12, 0.40, 0.40), 1.5)
	draw_line(Vector2(W, H), Vector2(vpx + vhw, vpy),       Color(0.25, 0.12, 0.40, 0.40), 1.5)
	draw_line(Vector2(0, 0), Vector2(vpx - vhw, vpy - vhh), Color(0.14, 0.07, 0.25, 0.22), 1.0)
	draw_line(Vector2(W, 0), Vector2(vpx + vhw, vpy - vhh), Color(0.14, 0.07, 0.25, 0.22), 1.0)

	# Wall texture lines
	for i in range(1, 5):
		var t  : float = float(i) / 5.0
		var lx : float = lerp(0.0, vpx - vhw, t)
		var rx : float = lerp(W,   vpx + vhw, t)
		var yb : float = lerp(H,   vpy,       t)
		var yt : float = lerp(0.0, vpy - vhh, t)
		draw_line(Vector2(lx, yb), Vector2(lx, yt), Color(0.08, 0.04, 0.16, 0.14), 1.0)
		draw_line(Vector2(rx, yb), Vector2(rx, yt), Color(0.08, 0.04, 0.16, 0.14), 1.0)

	_draw_torch(W, H, vpx, vpy, vhw, vhh, false)
	_draw_torch(W, H, vpx, vpy, vhw, vhh, true)

func _draw_torch(W: float, H: float, vpx: float, vpy: float,
				vhw: float, vhh: float, right: bool) -> void:
	var t      : float = 0.26
	var near_x : float = W if right else 0.0
	var far_x  : float = vpx + vhw if right else vpx - vhw
	var wx     : float = lerp(near_x, far_x, t)
	var wy_b   : float = lerp(H,   vpy,       t)
	var wy_t   : float = lerp(0.0, vpy - vhh, t)
	var wy     : float = lerp(wy_b, wy_t, 0.52)

	var stick  : float = W * 0.038 * (1.0 - t * 0.5)
	var sign_x : float = -1.0 if right else 1.0
	var tip_x  : float = wx + stick * sign_x
	var tip_y  : float = wy - stick * 0.3

	draw_line(Vector2(wx, wy), Vector2(tip_x, wy),    Color(0.45, 0.28, 0.12), 2.5)
	draw_line(Vector2(tip_x, wy), Vector2(tip_x, wy - stick * 0.5), Color(0.45, 0.28, 0.12), 2.0)

	var phase_off : float = 1.4 if right else 0.0
	var flicker   : float = 0.82 + sin(_t * 3.8 + phase_off) * 0.18
	var gr        : float = W * 0.060 * flicker * (1.0 - t * 0.35)

	draw_circle(Vector2(tip_x, tip_y), gr * 4.0,  Color(0.65, 0.35, 0.08, 0.04))
	draw_circle(Vector2(tip_x, tip_y), gr * 2.5,  Color(0.80, 0.46, 0.12, 0.09))
	draw_circle(Vector2(tip_x, tip_y), gr * 1.4,  Color(0.95, 0.60, 0.20, 0.18))
	draw_circle(Vector2(tip_x, tip_y), gr * 0.65, Color(1.00, 0.80, 0.38, 0.50))
	draw_circle(Vector2(tip_x, tip_y), gr * 0.28, Color(1.00, 0.95, 0.80, 0.88))

	var ftip_x : float = tip_x + sin(_t * 4.3) * gr * 0.2
	var ftip_y : float = tip_y - gr * 0.4
	draw_circle(Vector2(ftip_x, ftip_y), gr * 0.18, Color(1.0, 0.98, 0.7, 0.75))
	draw_circle(Vector2(wx, wy), gr * 5.5, Color(0.55, 0.30, 0.06, 0.05 * flicker))

# ── FIGURE ──────────────────────────────────────────────────────────────────
func _draw_fig(wd: Dictionary, W: float, H: float) -> void:
	var ph  : float = _t + float(wd["po"])
	var col : Color = wd["col"] as Color
	var sc  : float = float(wd["sc"])
	var fx  : float = float(wd["fx"])
	var fy  : float = float(wd["fy"])

	var cx   : float = W * fx
	var base : float = H * fy

	var persp : float = clamp((fy - VP_Y) / (1.0 - VP_Y), 0.25, 1.0)
	var fh    : float = H * 0.30 * sc * persp
	var hr    : float = fh * 0.19
	var ll    : float = fh * 0.54
	var al    : float = fh * 0.40
	var lw    : float = maxf(1.5, 2.8 * sc * persp)

	var bob   : float = sin(ph * 2.0) * fh * 0.030
	var hip   : Vector2 = Vector2(cx, base + bob)
	var sho   : Vector2 = Vector2(cx, base - fh + bob)
	var hd    : Vector2 = Vector2(cx, base - fh - hr * 1.15 + bob)

	var lsw   : float = sin(ph) * 0.54
	var asw   : float = sin(ph + PI) * 0.36

	draw_circle(Vector2(cx, base + lw), ll * 0.20, Color(0.0, 0.0, 0.0, 0.35 * persp))
	draw_line(hip, sho, Color(col.r, col.g, col.b, 0.10), lw * 4.0)
	draw_circle(hd, hr * 1.8, Color(col.r, col.g, col.b, 0.07))

	draw_line(hip, hip + Vector2(sin(lsw) * ll,  cos(lsw)  * ll * 0.84), col.darkened(0.22), lw)
	draw_line(hip, hip + Vector2(sin(-lsw) * ll, cos(-lsw) * ll * 0.84), col.darkened(0.22), lw)
	draw_line(hip, sho, col, lw * 1.45)
	draw_line(sho, sho + Vector2(sin(asw)  * al, cos(asw)  * al * 0.48), col.lightened(0.08), lw * 0.88)
	draw_line(sho, sho + Vector2(sin(-asw) * al, cos(-asw) * al * 0.48), col.lightened(0.08), lw * 0.88)

	draw_circle(hd, hr, col)
	draw_circle(hd + Vector2(hr * 0.30, hr * 0.05), hr * 0.24, col.darkened(0.62))

	if sc >= 1.0 and not _player_weapon.is_empty():
		_draw_weapon_idle(cx, base, fh, bob, ph)

# ── WEAPON ON FIGURE (idle/walking) ─────────────────────────────────────────
func _draw_weapon_idle(cx: float, base: float, fh: float, bob: float, ph: float) -> void:
	var hipy : float = base + bob
	var shy  : float = base - fh + bob
	match _player_weapon:
		"sword", "greatsword", "spear", "scythe":
			var wcol : Color = Color(0.78, 0.78, 0.88)
			match _player_weapon:
				"greatsword": wcol = Color(0.88, 0.78, 0.28)
				"spear":      wcol = Color(0.72, 0.82, 0.52)
				"scythe":     wcol = Color(0.65, 0.28, 0.82)
			var off : float = fh * 0.16
			var w1  : Vector2 = Vector2(cx - off, hipy - fh * 0.08)
			var w2  : Vector2 = Vector2(cx + off * 0.4, shy - fh * 0.28)
			var wlw : float = maxf(1.5, fh * 0.028)
			draw_line(w1, w2, wcol, wlw)
			if _player_weapon == "sword" or _player_weapon == "greatsword":
				var grd    : Vector2 = w1.lerp(w2, 0.28)
				var perp_v : Vector2 = (w2 - w1).normalized().rotated(PI * 0.5)
				draw_line(grd - perp_v * fh * 0.05, grd + perp_v * fh * 0.05,
					wcol, maxf(1.2, fh * 0.020))
		"axe", "hammer":
			var wcol : Color = Color(0.72, 0.60, 0.35)
			if _player_weapon == "axe": wcol = Color(0.88, 0.48, 0.18)
			var off  : float = fh * 0.15
			var w1   : Vector2 = Vector2(cx - off, hipy - fh * 0.10)
			var w2   : Vector2 = Vector2(cx + off * 0.3, shy - fh * 0.24)
			draw_line(w1, w2, wcol, maxf(1.8, fh * 0.034))
			draw_circle(w2, fh * 0.055, wcol)
		"dagger":
			var off : float = fh * 0.17
			var dp1 : Vector2 = Vector2(cx + off, hipy - fh * 0.05)
			var dp2 : Vector2 = Vector2(cx + off, hipy - fh * 0.26)
			draw_line(dp1, dp2, Color(0.82, 0.82, 0.92), maxf(1.5, fh * 0.026))
		"bow":
			var bc   : Vector2 = Vector2(cx + fh * 0.22, shy + fh * 0.06)
			var brad : float = fh * 0.22
			for j in range(7):
				var a1 : float = -0.70 + float(j) * (1.40 / 7.0)
				var a2 : float = -0.70 + float(j + 1) * (1.40 / 7.0)
				draw_line(bc + Vector2(cos(a1) * brad * 0.35, sin(a1) * brad),
					bc + Vector2(cos(a2) * brad * 0.35, sin(a2) * brad),
					Color(0.58, 0.40, 0.20), maxf(1.2, fh * 0.022))
		"wand":
			var asw  : float   = sin(ph + PI) * 0.36
			var al   : float   = fh * 0.40
			var hand : Vector2 = Vector2(cx, shy) + Vector2(sin(asw) * al, cos(asw) * al * 0.48)
			var tip  : Vector2 = hand + Vector2(fh * 0.14, -fh * 0.12)
			draw_line(hand, tip, Color(0.38, 0.22, 0.65), maxf(1.5, fh * 0.026))
			draw_circle(tip, fh * 0.034, Color(0.58, 0.32, 0.92, 0.85))
		"staff":
			var sx : float = cx + fh * 0.22
			draw_line(Vector2(sx, hipy + fh * 0.08), Vector2(sx, shy - fh * 0.50),
				Color(0.48, 0.32, 0.18), maxf(1.5, fh * 0.028))
			draw_circle(Vector2(sx, shy - fh * 0.50), fh * 0.040, Color(0.68, 0.48, 0.25))
