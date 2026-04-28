extends Control

var _t    := 0.0
var _wks  := []   # [{col, rx, ry, sc, po}]

func setup(companions: Array) -> void:
	_wks.clear()
	# Player — gold, centred, foreground
	_wks.append({"col": Color(0.92, 0.78, 0.22, 1.0), "rx": 0.0,  "ry": 1.0,  "sc": 1.0,  "po": 0.0})
	for i in companions.size():
		var c   = companions[i]
		var tc  = CompanionSystem.type_color(c.get("type", "fighter"))
		var sgn := 1.0 if i % 2 == 0 else -1.0
		_wks.append({
			"col": Color(tc.r, tc.g, tc.b, 0.88),
			"rx":  sgn * 0.22,
			"ry":  0.74 - i * 0.06,
			"sc":  0.66,
			"po":  TAU / 3.0 * float(i + 1)
		})

func _process(delta: float) -> void:
	_t = fmod(_t + delta * 5.5, TAU)
	queue_redraw()

func _draw() -> void:
	for wd in _wks:
		_draw_fig(wd)

func _draw_fig(wd: Dictionary) -> void:
	var ph  := _t + float(wd["po"])
	var col := wd["col"] as Color
	var sc  := float(wd["sc"])

	# Position — rx offsets left/right of centre; ry 1.0 = foreground bottom
	var cx  := size.x * (0.5 + float(wd["rx"]))
	var by  := size.y * (0.52 + float(wd["ry"]) * 0.40)

	# Figure dimensions
	var fh  := size.y * 0.30 * sc
	var hr  := fh * 0.17
	var ll  := fh * 0.52
	var al  := fh * 0.38
	var lw  := maxf(1.5, 2.4 * sc)

	# Vertical body bob (2× step frequency)
	var bob := sin(ph * 2.0) * fh * 0.025

	var hip := Vector2(cx, by + bob)
	var sho := Vector2(cx, by - fh + bob)
	var hd  := Vector2(cx, by - fh - hr * 1.15 + bob)

	# Swing angles
	var lsw := sin(ph) * 0.50
	var asw := sin(ph + PI) * 0.32

	# Shadow ellipse under feet
	var sh_col := Color(0.0, 0.0, 0.0, 0.28 * sc)
	for a in range(0, 360, 20):
		var rad := deg_to_rad(float(a))
		var ex  := cx + cos(rad) * ll * 0.28
		var ey  := by + ll * 0.85 + sin(rad) * ll * 0.08
		draw_circle(Vector2(ex, ey), lw * 0.6, sh_col)

	# Legs (from hip outward-downward)
	draw_line(hip, hip + Vector2(sin(lsw) * ll,  cos(lsw) * ll * 0.84), col.darkened(0.22), lw)
	draw_line(hip, hip + Vector2(sin(-lsw) * ll, cos(-lsw) * ll * 0.84), col.darkened(0.22), lw)

	# Torso
	draw_line(hip, sho, col, lw * 1.35)

	# Arms (hang from shoulder, swing opposite to legs)
	draw_line(sho, sho + Vector2(sin(asw) * al,  cos(asw) * al * 0.46), col.lightened(0.04), lw * 0.85)
	draw_line(sho, sho + Vector2(sin(-asw) * al, cos(-asw) * al * 0.46), col.lightened(0.04), lw * 0.85)

	# Head
	draw_circle(hd, hr, col)
	# Small dark face dot (visible from slight behind-angle)
	draw_circle(hd + Vector2(hr * 0.25, hr * 0.05), hr * 0.20, col.darkened(0.55))
