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

var _p_swing_prog : float = 0.0
var _e_swing_prog : float = 0.0
var _impact_p     : float = 0.0   # flash at enemy pos when player hits
var _impact_e     : float = 0.0   # flash at player pos when enemy hits
var _p_was_hit    : bool  = false
var _e_was_hit    : bool  = false
var _enemy_col    : Color = Color(0.85, 0.18, 0.18)
var _enemy_wtype  : String = "sword"

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
	_impact_p     = 0.0
	_impact_e     = 0.0
	_p_was_hit    = false
	_e_was_hit    = false
	_p_swing_prog = 0.0
	_e_swing_prog = 0.0
	_pick_enemy_appearance(ename)
	queue_redraw()

func _pick_enemy_appearance(ename: String) -> void:
	var en : String = ename.to_lower()
	if "reaper" in en or "death" in en:
		_enemy_col   = Color(0.88, 0.88, 0.92)
		_enemy_wtype = "scythe"
	elif "dragon" in en:
		_enemy_col   = Color(0.90, 0.38, 0.08)
		_enemy_wtype = "axe"
	elif "lich" in en or "mage" in en or "sorcerer" in en or "sage" in en or "witch" in en:
		_enemy_col   = Color(0.48, 0.22, 0.88)
		_enemy_wtype = "staff"
	elif "goblin" in en or "assassin" in en or "vampire" in en or "shadow" in en:
		_enemy_col   = Color(0.30, 0.72, 0.28)
		_enemy_wtype = "dagger"
	elif "giant" in en or "orc" in en or "hammer" in en or "titan" in en:
		_enemy_col   = Color(0.72, 0.42, 0.18)
		_enemy_wtype = "hammer"
	elif "angel" in en or "celestial" in en or "guardian" in en or "paladin" in en:
		_enemy_col   = Color(0.92, 0.85, 0.40)
		_enemy_wtype = "spear"
	elif "void" in en or "specter" in en or "specter" in en or "wraith" in en or "nightmare" in en:
		_enemy_col   = Color(0.35, 0.20, 0.70)
		_enemy_wtype = "staff"
	elif "demon" in en or "devil" in en or "hellfire" in en or "herald" in en:
		_enemy_col   = Color(0.88, 0.22, 0.12)
		_enemy_wtype = "sword"
	elif "knight" in en or "warrior" in en or "king" in en:
		_enemy_col   = Color(0.65, 0.65, 0.72)
		_enemy_wtype = "sword"
	elif "wolf" in en or "beast" in en or "werewolf" in en:
		_enemy_col   = Color(0.58, 0.48, 0.32)
		_enemy_wtype = "sword"
	else:
		_enemy_col   = Color(0.85, 0.18, 0.18)
		_enemy_wtype = "sword"

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
	_state        = 1
	_timer        = 0.0
	_p_was_hit    = hit
	_p_swing_prog = 0.0
	var ex : float = float(RANGE_EX[_range])
	if hit:
		_add_float(label, ex, FIG_Y - 0.26, Color(1.00, 0.90, 0.20), 30)
	else:
		_add_float(label, ex - 0.04, FIG_Y - 0.16, Color(0.60, 0.60, 0.60), 18)

func play_enemy_attack(label: String, hit: bool) -> void:
	_state        = 3
	_timer        = 0.0
	_e_was_hit    = hit
	_e_swing_prog = 0.0
	var px : float = float(RANGE_PX[_range])
	if hit:
		_add_float(label, px + 0.02, FIG_Y - 0.26, Color(0.95, 0.25, 0.25), 30)
	else:
		_add_float(label, px + 0.06, FIG_Y - 0.16, Color(0.25, 0.90, 0.45), 18)

func _add_float(text: String, fx: float, fy: float, col: Color, sz: int) -> void:
	_floats.append({"t": text, "x": fx, "y": fy, "a": 1.0, "col": col, "sz": sz})

# ── Process ─────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_t = fmod(_t + delta * 5.5, TAU)

	match _state:
		1:
			_timer += delta
			_p_swing_prog = sin(clamp(_timer / SWING_DUR, 0.0, 1.0) * PI)
			_p_lunge      = _p_swing_prog * 0.25
			if _timer >= SWING_DUR:
				if _p_was_hit:
					_impact_p = 1.0
				_state        = 2
				_timer        = 0.0
				_p_lunge      = 0.0
				_p_swing_prog = 0.0
		2:
			_timer += delta
			if _timer >= RESULT_DUR:
				_state = 0; _timer = 0.0; emit_signal("animation_done")
		3:
			_timer += delta
			_e_swing_prog = sin(clamp(_timer / SWING_DUR, 0.0, 1.0) * PI)
			_e_lunge      = _e_swing_prog * 0.25
			if _timer >= SWING_DUR:
				if _e_was_hit:
					_impact_e = 1.0
				_state        = 4
				_timer        = 0.0
				_e_lunge      = 0.0
				_e_swing_prog = 0.0
		4:
			_timer += delta
			if _timer >= RESULT_DUR:
				_state = 0; _timer = 0.0; emit_signal("animation_done")

	_impact_p = max(0.0, _impact_p - delta * 3.5)
	_impact_e = max(0.0, _impact_e - delta * 3.5)

	for ft in _floats:
		ft["a"] = float(ft["a"]) - delta * 1.1
		ft["y"] = float(ft["y"]) - delta * 0.038
	_floats = _floats.filter(func(ft): return float(ft["a"]) > 0.0)
	queue_redraw()

# ── Draw ─────────────────────────────────────────────────────────────────────
func _draw() -> void:
	var W : float = size.x
	var H : float = size.y
	if W < 10.0 or H < 10.0:
		return
	_bg(W, H)
	_draw_torches(W, H)
	_range_zones(W, H)
	_player(W, H)
	_enemy(W, H)
	_draw_impacts(W, H)
	_hpbar(W, H)
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

func _draw_torches(W: float, H: float) -> void:
	var vpx : float = W * 0.50
	var vpy : float = H * 0.30
	var vhw : float = W * 0.16
	var vhh : float = H * 0.10
	_draw_one_torch(W, H, vpx, vpy, vhw, vhh, false)
	_draw_one_torch(W, H, vpx, vpy, vhw, vhh, true)

func _draw_one_torch(W: float, H: float, vpx: float, vpy: float,
		vhw: float, vhh: float, right: bool) -> void:
	var t      : float = 0.24
	var near_x : float = W if right else 0.0
	var far_x  : float = vpx + vhw if right else vpx - vhw
	var wx     : float = lerp(near_x, far_x, t)
	var wy_b   : float = lerp(H,   vpy,       t)
	var wy_t   : float = lerp(0.0, vpy - vhh, t)
	var wy     : float = lerp(wy_b, wy_t, 0.52)

	var stick  : float = W * 0.040 * (1.0 - t * 0.5)
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

func _range_zones(W: float, H: float) -> void:
	var px   : float = float(RANGE_PX[_range]) * W
	var ex   : float = float(RANGE_EX[_range]) * W
	var gy   : float = H * (FIG_Y + 0.028)

	var rcol : Color = Color(0.85, 0.72, 0.18, 0.22)
	match _range:
		0: rcol = Color(0.90, 0.28, 0.18, 0.30)
		1: rcol = Color(0.85, 0.72, 0.18, 0.22)
		2: rcol = Color(0.25, 0.60, 0.90, 0.25)

	# Glowing ground oval under player
	var pr : float = W * 0.065
	for i in range(4):
		var fi  : float = float(i)
		var ra  : float = pr * (1.0 + fi * 0.55)
		var alp : float = rcol.a * (0.5 - fi * 0.10)
		if alp > 0.0:
			draw_circle(Vector2(px, gy), ra, Color(rcol.r, rcol.g, rcol.b, alp))

	# Glowing ground oval under enemy
	var er : float = W * 0.065
	for i in range(4):
		var fi  : float = float(i)
		var ra  : float = er * (1.0 + fi * 0.55)
		var alp : float = rcol.a * (0.5 - fi * 0.10)
		if alp > 0.0:
			draw_circle(Vector2(ex, gy), ra, Color(rcol.r, rcol.g, rcol.b, alp))

	# Range label
	var font = ThemeDB.fallback_font
	draw_string(font, Vector2(W*0.5, gy + H*0.036),
		RANGE_NAMES[_range],
		HORIZONTAL_ALIGNMENT_CENTER, -1, 12,
		Color(rcol.r, rcol.g, rcol.b, 0.85))

func _player(W: float, H: float) -> void:
	var px   : float = float(RANGE_PX[_range])
	var ex   : float = float(RANGE_EX[_range])
	var cx   : float = W * lerp(px, lerp(px, ex, 0.32), _p_lunge)
	var base : float = H * FIG_Y
	var fh   : float = H * 0.38
	var wtype : String = "sword"
	if not _weapons.is_empty() and _sel_w < _weapons.size():
		wtype = _weapons[_sel_w].get("weapon_type", "sword")
	_figure(cx, base, fh, Color(0.92, 0.78, 0.22), false, _p_swing_prog)
	# Compute lead arm endpoint for weapon
	var dir    : float   = 1.0
	var asw_l  : float   = lerp(-0.3 * dir, 1.1 * dir, _p_swing_prog)
	var al     : float   = fh * 0.38
	var bob    : float   = sin(_t * 1.6) * fh * 0.012
	var sho    : Vector2 = Vector2(cx, base - fh + bob)
	var hand   : Vector2 = sho + Vector2(sin(asw_l) * al, cos(asw_l) * al * 0.50)
	var arm_dir: Vector2 = (hand - sho).normalized()
	_weapon(hand, arm_dir, fh, wtype, false, _p_swing_prog)

func _enemy(W: float, H: float) -> void:
	var ex   : float = float(RANGE_EX[_range])
	var px   : float = float(RANGE_PX[_range])
	var cx   : float = W * lerp(ex, lerp(ex, px, 0.32), _e_lunge)
	var base : float = H * FIG_Y
	var fh   : float = H * 0.34
	var pct  : float = float(_enemy_hp) / float(max(1, _enemy_max_hp))
	var col  : Color = _enemy_col if pct > 0.30 else _enemy_col.darkened(0.40)
	_figure(cx, base, fh, col, true, _e_swing_prog)
	# Compute lead arm endpoint for weapon (mirrored)
	var dir    : float   = -1.0
	var asw_l  : float   = lerp(-0.3 * dir, 1.1 * dir, _e_swing_prog)
	var al     : float   = fh * 0.38
	var bob    : float   = sin(_t * 1.6) * fh * 0.012
	var sho    : Vector2 = Vector2(cx, base - fh + bob)
	var hand   : Vector2 = sho + Vector2(sin(asw_l) * al, cos(asw_l) * al * 0.50)
	var arm_dir: Vector2 = (hand - sho).normalized()
	_weapon(hand, arm_dir, fh, _enemy_wtype, true, _e_swing_prog)

func _figure(cx: float, base: float, fh: float, col: Color, mir: bool, swing_p: float) -> void:
	var hr  : float = fh * 0.17
	var ll  : float = fh * 0.50
	var al  : float = fh * 0.38
	var lw  : float = maxf(2.5, fh * 0.050)
	var bob : float = sin(_t * 1.6) * fh * 0.012
	var dir : float = -1.0 if mir else 1.0

	var hip : Vector2 = Vector2(cx, base + bob)
	var sho : Vector2 = Vector2(cx, base - fh + bob)
	var hd  : Vector2 = Vector2(cx, base - fh - hr * 1.20 + bob)

	# Combat stance: legs slightly apart, no walking swing
	var loff : float = fh * 0.10
	var lleg : Vector2 = hip + Vector2(-loff, ll * 0.88)
	var rleg : Vector2 = hip + Vector2( loff, ll * 0.88)

	# Arms: lead arm driven by swing_p, off arm back
	var asw_l : float = lerp(-0.3 * dir, 1.1 * dir, swing_p)
	var asw_o : float = 0.2 * dir   # off-arm slightly back

	# Shadow
	draw_circle(Vector2(cx, base + lw * 0.5), ll * 0.16, Color(0, 0, 0, 0.30))
	# Body glow
	draw_line(hip, sho, Color(col.r, col.g, col.b, 0.10), lw * 4.5)
	# Head glow
	draw_circle(hd, hr * 2.0, Color(col.r, col.g, col.b, 0.06))

	# Legs (combat spread)
	draw_line(hip, lleg, col.darkened(0.22), lw)
	draw_line(hip, rleg, col.darkened(0.22), lw)

	# Torso
	draw_line(hip, sho, col, lw * 1.45)

	# Lead arm (swing_p drives sweep)
	var lead_end : Vector2 = sho + Vector2(sin(asw_l) * al, cos(asw_l) * al * 0.50)
	draw_line(sho, lead_end, col.lightened(0.10), lw * 0.92)

	# Off arm
	var off_end : Vector2 = sho + Vector2(sin(asw_o) * al, cos(asw_o) * al * 0.50)
	draw_line(sho, off_end, col.darkened(0.10), lw * 0.80)

	# Head
	draw_circle(hd, hr, col)
	draw_circle(hd + Vector2(hr * 0.28 * dir, hr * 0.06), hr * 0.24, col.darkened(0.62))

func _weapon(hand_pos: Vector2, arm_dir: Vector2, fh: float, wtype: String, mir: bool, swing_p: float) -> void:
	var d : float = -1.0 if mir else 1.0

	match wtype:
		"sword":
			var wcol : Color  = Color(0.78, 0.78, 0.88)
			var wlen : float  = fh * 0.92
			var wlw  : float  = maxf(2.0, fh * 0.040)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol, wlw)
			var grd  : Vector2 = hand_pos + arm_dir * wlen * 0.15
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			draw_line(grd - perp * fh * 0.08, grd + perp * fh * 0.08, wcol, maxf(1.5, fh * 0.028))

		"greatsword":
			var wcol : Color  = Color(0.88, 0.78, 0.28)
			var wlen : float  = fh * 1.20
			var wlw  : float  = maxf(2.5, fh * 0.055)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol, wlw)
			var grd  : Vector2 = hand_pos + arm_dir * wlen * 0.12
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			draw_line(grd - perp * fh * 0.10, grd + perp * fh * 0.10, wcol, maxf(2.0, fh * 0.036))

		"spear":
			var wcol : Color  = Color(0.72, 0.82, 0.52)
			var wlen : float  = fh * 1.30
			var wlw  : float  = maxf(1.8, fh * 0.030)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol, wlw)
			# Spear tip triangle
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			draw_line(tip, tip + arm_dir * fh * 0.12, Color(0.90, 0.95, 0.65), maxf(2.0, fh * 0.038))
			draw_line(tip - perp * fh * 0.04, tip + arm_dir * fh * 0.12, wcol, maxf(1.5, fh * 0.022))
			draw_line(tip + perp * fh * 0.04, tip + arm_dir * fh * 0.12, wcol, maxf(1.5, fh * 0.022))

		"scythe":
			var wcol : Color  = Color(0.65, 0.28, 0.82)
			var wlen : float  = fh * 1.10
			var wlw  : float  = maxf(2.0, fh * 0.036)
			var shaft_tip : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, shaft_tip, wcol.darkened(0.20), wlw)
			# Curved blade: arc from shaft tip
			var blade_base : Vector2 = shaft_tip
			var perp       : Vector2 = arm_dir.rotated(PI * 0.5)
			for j in range(6):
				var fj  : float = float(j) / 5.0
				var fj1 : float = float(j + 1) / 5.0
				var p0  : Vector2 = blade_base + arm_dir * fh * 0.0 + perp * lerp(0.0, fh * 0.30, fj)  - arm_dir * lerp(0.0, fh * 0.28, fj * fj)
				var p1  : Vector2 = blade_base + arm_dir * fh * 0.0 + perp * lerp(0.0, fh * 0.30, fj1) - arm_dir * lerp(0.0, fh * 0.28, fj1 * fj1)
				draw_line(p0, p1, wcol, maxf(1.5, fh * 0.028))

		"axe":
			var wcol : Color  = Color(0.88, 0.48, 0.18)
			var wlen : float  = fh * 0.80
			var wlw  : float  = maxf(2.0, fh * 0.040)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol.darkened(0.15), wlw)
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			draw_line(tip - perp * fh * 0.14, tip + perp * fh * 0.14, wcol, maxf(3.0, fh * 0.055))
			draw_line(tip, tip + arm_dir * fh * 0.10 + perp * fh * 0.06, wcol, maxf(2.0, fh * 0.040))
			draw_line(tip, tip + arm_dir * fh * 0.10 - perp * fh * 0.06, wcol, maxf(2.0, fh * 0.040))

		"hammer":
			var wcol : Color  = Color(0.72, 0.60, 0.35)
			var wlen : float  = fh * 0.78
			var wlw  : float  = maxf(2.0, fh * 0.042)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol.darkened(0.10), wlw)
			# Hammer head box
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			var h1   : Vector2 = tip - perp * fh * 0.10 + arm_dir * fh * 0.04
			var h2   : Vector2 = tip + perp * fh * 0.10 + arm_dir * fh * 0.04
			var h3   : Vector2 = tip + perp * fh * 0.10 + arm_dir * fh * 0.18
			var h4   : Vector2 = tip - perp * fh * 0.10 + arm_dir * fh * 0.18
			draw_line(h1, h2, wcol, maxf(2.0, fh * 0.036))
			draw_line(h2, h3, wcol, maxf(2.0, fh * 0.036))
			draw_line(h3, h4, wcol, maxf(2.0, fh * 0.036))
			draw_line(h4, h1, wcol, maxf(2.0, fh * 0.036))

		"dagger":
			var dcol : Color  = Color(0.82, 0.82, 0.92)
			var wlen : float  = fh * 0.45
			var wlw  : float  = maxf(1.5, fh * 0.028)
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, dcol, wlw)
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			draw_line(hand_pos - perp * fh * 0.04, hand_pos + perp * fh * 0.04,
				dcol, maxf(1.2, fh * 0.020))

		"bow":
			var bcol : Color  = Color(0.58, 0.40, 0.20)
			var brad : float  = fh * 0.26
			var perp : Vector2 = arm_dir.rotated(PI * 0.5)
			# Draw arc (7 segments, bow curves perpendicular to arm)
			for j in range(7):
				var fj  : float   = float(j)
				var fj1 : float   = float(j + 1)
				var a1  : float   = lerp(-0.70, 0.70, fj / 7.0)
				var a2  : float   = lerp(-0.70, 0.70, fj1 / 7.0)
				var p0  : Vector2 = hand_pos + perp * sin(a1) * brad + arm_dir * (cos(a1) - 1.0) * brad * 0.40
				var p1  : Vector2 = hand_pos + perp * sin(a2) * brad + arm_dir * (cos(a2) - 1.0) * brad * 0.40
				draw_line(p0, p1, bcol, maxf(1.5, fh * 0.026))
			# String
			var s0 : Vector2 = hand_pos + perp * (-brad * 0.95)
			var s1 : Vector2 = hand_pos + perp * ( brad * 0.95)
			draw_line(s0, s1, Color(0.75, 0.65, 0.45, 0.65), 1.0)

		"wand":
			var wcol : Color  = Color(0.38, 0.22, 0.65)
			var wlen : float  = fh * 0.55
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			draw_line(hand_pos, tip, wcol, maxf(2.0, fh * 0.034))
			draw_circle(tip, fh * 0.048, Color(0.58, 0.32, 0.92, 0.90))
			draw_circle(tip, fh * 0.028, Color(0.80, 0.60, 1.00, 0.70))

		"staff":
			var scol : Color  = Color(0.48, 0.32, 0.18)
			var wlen : float  = fh * 1.20
			var tip  : Vector2 = hand_pos + arm_dir * wlen
			var base2: Vector2 = hand_pos - arm_dir * fh * 0.30
			draw_line(base2, tip, scol, maxf(2.0, fh * 0.038))
			draw_circle(tip, fh * 0.058, Color(0.68, 0.48, 0.25))
			draw_circle(tip, fh * 0.038, Color(0.92, 0.72, 0.45, 0.80))

func _draw_impacts(W: float, H: float) -> void:
	# Impact flash at enemy position (player hit)
	if _impact_p > 0.0:
		var ex  : float   = float(RANGE_EX[_range]) * W
		var ey  : float   = H * (FIG_Y - 0.20)
		var imp : float   = _impact_p
		# Expanding rings (fade outward as imp decays)
		for i in range(5):
			var fi    : float = float(i)
			var ring_r: float = H * 0.06 * (1.0 + fi * 0.6) * (1.0 - imp * 0.5)
			var ring_a: float = imp * (0.55 - fi * 0.08)
			if ring_a > 0.0:
				draw_circle(Vector2(ex, ey), ring_r, Color(1.0, 0.82, 0.20, ring_a))
		# Spark lines (8 radial)
		var slen : float = H * 0.09 * imp
		for i in range(8):
			var fi    : float   = float(i)
			var angle : float   = fi * PI / 4.0 + _t * 3.0
			var sa    : float   = imp * 0.90
			var p0    : Vector2 = Vector2(ex, ey) + Vector2(cos(angle), sin(angle)) * slen * 0.15
			var p1    : Vector2 = Vector2(ex, ey) + Vector2(cos(angle), sin(angle)) * slen
			draw_line(p0, p1, Color(1.0, 0.95, 0.35, sa), maxf(1.0, slen * 0.06))
		# Core flash
		draw_circle(Vector2(ex, ey), H * 0.028 * imp, Color(1.0, 0.98, 0.80, imp * 0.90))

	# Impact flash at player position (enemy hit)
	if _impact_e > 0.0:
		var px  : float   = float(RANGE_PX[_range]) * W
		var py  : float   = H * (FIG_Y - 0.22)
		var imp : float   = _impact_e
		for i in range(5):
			var fi    : float = float(i)
			var ring_r: float = H * 0.06 * (1.0 + fi * 0.6) * (1.0 - imp * 0.5)
			var ring_a: float = imp * (0.55 - fi * 0.08)
			if ring_a > 0.0:
				draw_circle(Vector2(px, py), ring_r, Color(0.95, 0.25, 0.18, ring_a))
		var slen : float = H * 0.09 * imp
		for i in range(8):
			var fi    : float   = float(i)
			var angle : float   = fi * PI / 4.0 + _t * 3.0 + PI * 0.20
			var sa    : float   = imp * 0.90
			var p0    : Vector2 = Vector2(px, py) + Vector2(cos(angle), sin(angle)) * slen * 0.15
			var p1    : Vector2 = Vector2(px, py) + Vector2(cos(angle), sin(angle)) * slen
			draw_line(p0, p1, Color(1.0, 0.45, 0.20, sa), maxf(1.0, slen * 0.06))
		draw_circle(Vector2(px, py), H * 0.028 * imp, Color(1.0, 0.70, 0.50, imp * 0.90))

func _hpbar(W: float, H: float) -> void:
	var bw   : float = W * 0.72
	var bh   : float = H * 0.048
	var bx   : float = (W - bw) * 0.5
	var by   : float = H * 0.034

	# Outer border
	draw_rect(Rect2(bx - 2.0, by - 2.0, bw + 4.0, bh + 4.0), Color(0.10, 0.05, 0.18))
	# Background
	draw_rect(Rect2(bx, by, bw, bh), Color(0.06, 0.03, 0.10))

	var pct  : float = float(_enemy_hp) / float(max(1, _enemy_max_hp))
	var hcol : Color = Color(0.22, 0.78, 0.28)
	if pct <= 0.66:
		hcol = Color(0.90, 0.75, 0.12)
	if pct <= 0.33:
		hcol = Color(0.90, 0.22, 0.18)

	if pct > 0.0:
		draw_rect(Rect2(bx, by, bw * pct, bh), hcol)

	# Segmented dividers at 25%, 50%, 75%
	for i in range(1, 4):
		var dx : float = bx + bw * (float(i) * 0.25)
		draw_line(Vector2(dx, by), Vector2(dx, by + bh), Color(0.0, 0.0, 0.0, 0.35), 1.0)

	# HP bar top highlight
	draw_line(Vector2(bx, by + 1.0), Vector2(bx + bw * pct, by + 1.0),
		Color(1.0, 1.0, 1.0, 0.14), 1.0)

	# Name and HP text
	var font = ThemeDB.fallback_font
	draw_string(font,
		Vector2(W * 0.5, by + bh * 0.82),
		"%s   HP %d / %d" % [_enemy_name.to_upper(), _enemy_hp, _enemy_max_hp],
		HORIZONTAL_ALIGNMENT_CENTER, W * 0.70, 11,
		Color(1.0, 0.92, 0.72, 0.92))

func _floats_draw(W: float, H: float) -> void:
	var font = ThemeDB.fallback_font
	for ft in _floats:
		var a   : float = float(ft["a"])
		var col : Color = ft["col"] as Color
		col.a = a
		draw_string(font,
			Vector2(float(ft["x"]) * W, float(ft["y"]) * H),
			ft["t"] as String,
			HORIZONTAL_ALIGNMENT_CENTER, -1, int(ft["sz"]), col)
