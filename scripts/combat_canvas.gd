extends Control

signal animation_done

# Range: 0=CLOSE  1=MEDIUM  2=FAR
const RANGE_NAMES = ["CLOSE", "MEDIUM", "FAR"]
const RANGE_PX    = [0.28, 0.18, 0.10]   # player centre-x fraction
const RANGE_EX    = [0.72, 0.82, 0.90]   # enemy centre-x fraction
const FIG_Y       = 0.80                  # figure base-y fraction
const SWING_DUR   = 0.40
const RESULT_DUR  = 0.65

var _t          : float = 0.0
var _range      : int   = 1
var _state      : int   = 0   # 0=IDLE 1=P_SWING 2=P_RESULT 3=E_SWING 4=E_RESULT
var _timer      : float = 0.0
var _p_lunge    : float = 0.0
var _e_lunge    : float = 0.0

var _enemy_name   : String = "Enemy"
var _enemy_hp     : int    = 0
var _enemy_max_hp : int    = 0
var _weapons      : Array  = []
var _sel_w        : int    = 0

var _floats : Array = []   # {t, x, y, a, col, sz}

# ── Public API ──────────────────────────────────────────────────────────────
func setup_combat(ename: String, ehp: int, weapons: Array) -> void:
	_enemy_name   = ename
	_enemy_hp     = ehp
	_enemy_max_hp = ehp
	_weapons      = weapons
	_range        = 1
	_state        = 0
	_floats.clear()
	queue_redraw()

func update_enemy_hp(hp: int) -> void:
	_enemy_hp = max(0, hp)
	queue_redraw()

func set_range(r: int) -> void:
	_range = clamp(r, 0, 2)
	queue_redraw()

func set_selected_weapon(idx: int) -> void:
	_sel_w = idx
	queue_redraw()

func get_range() -> int:
	return _range

func is_busy() -> bool:
	return _state != 0

func play_player_attack(label: String, hit: bool) -> void:
	_state = 1; _timer = 0.0
	var ex : float = RANGE_EX[_range]
	if hit:
		_add_float(label, ex, FIG_Y - 0.22, Color(1.00, 0.90, 0.20), 26)
	else:
		_add_float("MISS", ex - 0.04, FIG_Y - 0.14, Color(0.60, 0.60, 0.60), 22)

func play_enemy_attack(label: String, hit: bool) -> void:
	_state = 3; _timer = 0.0
	var px : float = RANGE_PX[_range]
	if hit:
		_add_float(label, px + 0.02, FIG_Y - 0.22, Color(0.95, 0.25, 0.25), 26)
	else:
		_add_float("EVADE", px + 0.06, FIG_Y - 0.14, Color(0.25, 0.90, 0.45), 22)

func _add_float(text: String, fx: float, fy: float, col: Color, sz: int) -> void:
	_floats.append({"t": text, "x": fx, "y": fy, "a": 1.0, "col": col, "sz": sz})

# ── Process ─────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_t = fmod(_t + delta * 5.5, TAU)
	match _state:
		1:
			_timer += delta
			_p_lunge = sin(clamp(_timer / SWING_DUR, 0.0, 1.0) * PI)
			if _timer >= SWING_DUR:
				_state = 2; _timer = 0.0; _p_lunge = 0.0
		2:
			_timer += delta
			if _timer >= RESULT_DUR:
				_state = 0; _timer = 0.0; emit_signal("animation_done")
		3:
			_timer += delta
			_e_lunge = sin(clamp(_timer / SWING_DUR, 0.0, 1.0) * PI)
			if _timer >= SWING_DUR:
				_state = 4; _timer = 0.0; _e_lunge = 0.0
		4:
			_timer += delta
			if _timer >= RESULT_DUR:
				_state = 0; _timer = 0.0; emit_signal("animation_done")

	for ft in _floats:
		ft["a"]  = float(ft["a"]) - delta * 1.2
		ft["y"]  = float(ft["y"]) - delta * 0.042
	_floats = _floats.filter(func(ft): return float(ft["a"]) > 0.0)
	queue_redraw()

# ── Draw ─────────────────────────────────────────────────────────────────────
func _draw() -> void:
	var W : float = size.x
	var H : float = size.y
	if W < 10.0 or H < 10.0: return
	_bg(W, H)
	_player(W, H)
	_enemy(W, H)
	_hpbar(W, H)
	_range_line(W, H)
	_floats_draw(W, H)

func _bg(W: float, H: float) -> void:
	var vpx : float = W * 0.50
	var vpy : float = H * 0.30
	var vhw : float = W * 0.16
	var vhh : float = H * 0.10

	draw_rect(Rect2(0, 0, W, H), Color(0.018, 0.009, 0.040))

	draw_polygon(
		PackedVector2Array([Vector2(0,0), Vector2(W,0), Vector2(vpx+vhw,vpy-vhh), Vector2(vpx-vhw,vpy-vhh)]),
		PackedColorArray([Color(0.010,0.005,0.020), Color(0.010,0.005,0.020), Color(0.018,0.009,0.038), Color(0.018,0.009,0.038)]))

	draw_polygon(
		PackedVector2Array([Vector2(0,0), Vector2(0,H), Vector2(vpx-vhw,vpy), Vector2(vpx-vhw,vpy-vhh)]),
		PackedColorArray([Color(0.022,0.011,0.045), Color(0.040,0.020,0.078), Color(0.044,0.022,0.085), Color(0.026,0.013,0.052)]))

	draw_polygon(
		PackedVector2Array([Vector2(W,0), Vector2(W,H), Vector2(vpx+vhw,vpy), Vector2(vpx+vhw,vpy-vhh)]),
		PackedColorArray([Color(0.022,0.011,0.045), Color(0.040,0.020,0.078), Color(0.044,0.022,0.085), Color(0.026,0.013,0.052)]))

	draw_polygon(
		PackedVector2Array([Vector2(0,H), Vector2(W,H), Vector2(vpx+vhw,vpy), Vector2(vpx-vhw,vpy)]),
		PackedColorArray([Color(0.055,0.028,0.088), Color(0.055,0.028,0.088), Color(0.026,0.013,0.050), Color(0.026,0.013,0.050)]))

	for i in range(1, 5):
		var t : float  = float(i) / 5.0
		var ly : float = lerp(H, vpy, t)
		draw_line(Vector2(lerp(0.0,vpx-vhw,t), ly), Vector2(lerp(W,vpx+vhw,t), ly),
			Color(0.18,0.09,0.28, lerp(0.14, 0.03, t)), 1.0)

	draw_line(Vector2(0,H), Vector2(vpx-vhw,vpy), Color(0.22,0.11,0.36,0.30), 1.5)
	draw_line(Vector2(W,H), Vector2(vpx+vhw,vpy), Color(0.22,0.11,0.36,0.30), 1.5)
	draw_line(Vector2(0,0), Vector2(vpx-vhw,vpy-vhh), Color(0.12,0.06,0.22,0.18), 1.0)
	draw_line(Vector2(W,0), Vector2(vpx+vhw,vpy-vhh), Color(0.12,0.06,0.22,0.18), 1.0)

	for i in range(3):
		draw_circle(Vector2(vpx, vpy-vhh*0.3), vhw*(0.4+float(i)*0.9),
			Color(0.50,0.28,0.08, 0.04-float(i)*0.012))

func _player(W: float, H: float) -> void:
	var px   : float = RANGE_PX[_range]
	var ex   : float = RANGE_EX[_range]
	var cx   : float = W * lerp(px, lerp(px, ex, 0.30), _p_lunge)
	var base : float = H * FIG_Y
	var fh   : float = H * 0.32
	_figure(cx, base, fh, Color(0.92, 0.78, 0.22), false)
	var wtype : String = "sword"
	if not _weapons.is_empty() and _sel_w < _weapons.size():
		wtype = _weapons[_sel_w].get("weapon_type", "sword")
	_weapon(cx, base, fh, wtype, false)

func _enemy(W: float, H: float) -> void:
	var ex   : float = RANGE_EX[_range]
	var px   : float = RANGE_PX[_range]
	var cx   : float = W * lerp(ex, lerp(ex, px, 0.30), _e_lunge)
	var base : float = H * FIG_Y
	var fh   : float = H * 0.30
	var pct  : float = float(_enemy_hp) / float(max(1, _enemy_max_hp))
	var col  : Color = Color(0.85, 0.18, 0.18) if pct > 0.30 else Color(0.55, 0.12, 0.12)
	_figure(cx, base, fh, col, true)
	_weapon(cx, base, fh, "sword", true)

func _figure(cx: float, base: float, fh: float, col: Color, mir: bool) -> void:
	var hr  : float = fh * 0.18
	var ll  : float = fh * 0.52
	var al  : float = fh * 0.38
	var lw  : float = maxf(2.0, fh * 0.046)
	var bob : float = sin(_t * 2.0) * fh * 0.025
	var hip : Vector2 = Vector2(cx, base + bob)
	var sho : Vector2 = Vector2(cx, base - fh + bob)
	var hd  : Vector2 = Vector2(cx, base - fh - hr * 1.15 + bob)
	var dir : float = -1.0 if mir else 1.0
	var lsw : float = sin(_t) * 0.52 * dir
	var asw : float = sin(_t + PI) * 0.34 * dir

	draw_circle(Vector2(cx, base + lw), ll * 0.18, Color(0,0,0,0.28))
	draw_line(hip, sho, Color(col.r,col.g,col.b,0.10), lw * 4.0)
	draw_circle(hd, hr * 1.8, Color(col.r,col.g,col.b,0.07))

	draw_line(hip, hip + Vector2(sin(lsw)*ll,  cos(lsw)*ll*0.84),  col.darkened(0.22), lw)
	draw_line(hip, hip + Vector2(sin(-lsw)*ll, cos(-lsw)*ll*0.84), col.darkened(0.22), lw)
	draw_line(hip, sho, col, lw * 1.4)
	draw_line(sho, sho + Vector2(sin(asw)*al,  cos(asw)*al*0.48),  col.lightened(0.08), lw*0.88)
	draw_line(sho, sho + Vector2(sin(-asw)*al, cos(-asw)*al*0.48), col.lightened(0.08), lw*0.88)
	draw_circle(hd, hr, col)
	draw_circle(hd + Vector2(hr*0.28*dir, hr*0.05), hr*0.22, col.darkened(0.60))

func _weapon(cx: float, base: float, fh: float, wtype: String, mir: bool) -> void:
	var bob   : float = sin(_t * 2.0) * fh * 0.025
	var shy   : float = base - fh + bob
	var hipy  : float = base + bob
	var d     : float = -1.0 if mir else 1.0

	match wtype:
		"sword", "greatsword", "spear", "scythe":
			var wcol : Color
			match wtype:
				"greatsword": wcol = Color(0.88, 0.78, 0.28)
				"spear":      wcol = Color(0.72, 0.82, 0.52)
				"scythe":     wcol = Color(0.65, 0.28, 0.82)
				_:            wcol = Color(0.78, 0.78, 0.88)
			var wlw : float = maxf(2.0, fh * (0.055 if wtype == "greatsword" else 0.038))
			var w1  : Vector2 = Vector2(cx + d*fh*0.05, hipy - fh*0.12)
			var w2  : Vector2 = Vector2(cx - d*fh*0.24, shy - fh*0.42)
			draw_line(w1, w2, wcol, wlw)
			var grd  : Vector2 = w1.lerp(w2, 0.22)
			var perp : Vector2 = (w2-w1).normalized().rotated(PI*0.5)
			draw_line(grd - perp*fh*0.07, grd + perp*fh*0.07, wcol, maxf(1.5, fh*0.028))
		"axe", "hammer":
			var wcol : Color = Color(0.88, 0.48, 0.18) if wtype == "axe" else Color(0.72, 0.60, 0.35)
			var w1   : Vector2 = Vector2(cx + d*fh*0.05, hipy - fh*0.12)
			var w2   : Vector2 = Vector2(cx - d*fh*0.20, shy - fh*0.34)
			draw_line(w1, w2, wcol, maxf(2.0, fh*0.044))
			draw_circle(w2, fh*0.07, wcol)
		"dagger":
			var dp1 : Vector2 = Vector2(cx - d*fh*0.16, hipy - fh*0.08)
			var dp2 : Vector2 = Vector2(cx - d*fh*0.16, hipy - fh*0.28)
			draw_line(dp1, dp2, Color(0.82, 0.82, 0.92), maxf(1.5, fh*0.030))
		"bow":
			var bc   : Vector2 = Vector2(cx + d*fh*0.18, shy - fh*0.08)
			var brad : float   = fh * 0.24
			for j in range(7):
				var a1 : float = -0.75 + float(j)*(1.5/7.0)
				var a2 : float = -0.75 + float(j+1)*(1.5/7.0)
				draw_line(bc+Vector2(cos(a1)*brad*0.35, sin(a1)*brad),
					bc+Vector2(cos(a2)*brad*0.35, sin(a2)*brad),
					Color(0.58,0.40,0.20), maxf(1.5, fh*0.028))
			draw_line(bc+Vector2(cos(-0.75)*brad*0.35, sin(-0.75)*brad),
				bc+Vector2(cos(0.75)*brad*0.35, sin(0.75)*brad),
				Color(0.75,0.65,0.45,0.65), 1.0)
		"wand":
			var asw  : float   = sin(_t + PI) * 0.34
			var hand : Vector2 = Vector2(cx, shy) + Vector2(sin(asw)*fh*0.38, cos(asw)*fh*0.38*0.48)
			var tip  : Vector2 = hand + Vector2(-d*fh*0.22, -fh*0.18)
			draw_line(hand, tip, Color(0.38,0.22,0.65), maxf(2.0, fh*0.036))
			draw_circle(tip, fh*0.042, Color(0.58,0.32,0.92,0.88))
		"staff":
			var sx : float = cx - d*fh*0.18
			draw_line(Vector2(sx, hipy+fh*0.12), Vector2(sx, shy-fh*0.65),
				Color(0.48,0.32,0.18), maxf(2.0, fh*0.036))
			draw_circle(Vector2(sx, shy-fh*0.65), fh*0.05, Color(0.68,0.48,0.25))

func _hpbar(W: float, H: float) -> void:
	var bw : float = W * 0.70
	var bh : float = H * 0.044
	var bx : float = (W - bw) * 0.5
	var by : float = H * 0.036
	draw_rect(Rect2(bx-2, by-2, bw+4, bh+4), Color(0.10,0.05,0.18))
	draw_rect(Rect2(bx, by, bw, bh),          Color(0.06,0.03,0.10))
	var pct  : float = float(_enemy_hp) / float(max(1, _enemy_max_hp))
	var hcol : Color = Color(0.80,0.20,0.20) if pct > 0.30 else Color(0.90,0.62,0.12)
	if pct > 0.0:
		draw_rect(Rect2(bx, by, bw*pct, bh), hcol)
	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(W*0.5, by + bh*0.80),
		"%s   HP %d / %d" % [_enemy_name.to_upper(), _enemy_hp, _enemy_max_hp],
		HORIZONTAL_ALIGNMENT_CENTER, W*0.70, 11, Color(1.0,0.92,0.72,0.92))

func _range_line(W: float, H: float) -> void:
	var px   : float = RANGE_PX[_range] * W
	var ex   : float = RANGE_EX[_range] * W
	var y    : float = H * (FIG_Y + 0.068)
	var rcol : Color = Color(0.85, 0.72, 0.18, 0.28)
	match _range:
		0: rcol = Color(0.90, 0.28, 0.18, 0.40)
		1: rcol = Color(0.85, 0.72, 0.18, 0.28)
		2: rcol = Color(0.25, 0.60, 0.90, 0.32)
	for i in range(9):
		if i % 2 == 0:
			draw_line(Vector2(lerp(px,ex,float(i)/9.0), y),
				Vector2(lerp(px,ex,float(i+1)/9.0), y), rcol, 1.5)
	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(W*0.5, y+H*0.024), RANGE_NAMES[_range],
		HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(rcol.r,rcol.g,rcol.b,0.85))

func _floats_draw(W: float, H: float) -> void:
	var font = ThemeDB.fallback_font
	for ft in _floats:
		var a   : float = float(ft["a"])
		var col : Color = (ft["col"] as Color)
		col.a = a
		draw_string(font, Vector2(float(ft["x"])*W, float(ft["y"])*H),
			ft["t"] as String, HORIZONTAL_ALIGNMENT_CENTER, -1, int(ft["sz"]), col)
