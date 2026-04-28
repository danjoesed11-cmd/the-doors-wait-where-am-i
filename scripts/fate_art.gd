class_name FateArt
extends Control

var fate_id: String = ""
var fate_type: int = 0
var enemy_name: String = ""

func setup(f_id: String, f_type: int, e_name: String = "") -> void:
	fate_id = f_id
	fate_type = f_type
	enemy_name = e_name
	queue_redraw()

func _draw() -> void:
	if size.x < 10 or size.y < 10:
		return
	var w = size.x; var h = size.y
	var cx = w * 0.5; var cy = h * 0.5
	match fate_type:
		0: _draw_death(w, h, cx, cy)
		1: _draw_win(w, h, cx, cy)
		2: _draw_combat(w, h, cx, cy)
		3: _draw_trap(w, h, cx, cy)
		4: _draw_boon(w, h, cx, cy)
		5: _draw_story(w, h, cx, cy)
		6: _draw_weapon(w, h, cx, cy)
		7: _draw_companion(w, h, cx, cy)
		8: _draw_item(w, h, cx, cy)
		9: _draw_village_scene(w, h, cx, cy)
		10: _draw_wedding_scene(w, h, cx, cy)
		11: _draw_camp_scene(w, h, cx, cy)

func _poly(pts: Array, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array(pts), c)

func _oval(center: Vector2, rx: float, ry: float, c: Color, segs: int = 20) -> void:
	var arr = PackedVector2Array()
	for i in range(segs):
		var a = TAU * i / segs
		arr.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(arr, c)

# ── DEATH: skull with blood drips ────────────────────────────────────
func _draw_death(w, h, cx, cy):
	draw_rect(Rect2(0, 0, w, h), Color(0.22, 0, 0, 0.45))
	var r = min(w * 0.28, h * 0.38)
	var hy = cy - h * 0.04
	_oval(Vector2(cx, hy), r, r * 0.9, Color(0.78, 0.74, 0.68))
	_oval(Vector2(cx - r*0.32, hy - r*0.07), r*0.2, r*0.23, Color(0.06, 0.02, 0.10))
	_oval(Vector2(cx + r*0.32, hy - r*0.07), r*0.2, r*0.23, Color(0.06, 0.02, 0.10))
	draw_circle(Vector2(cx - r*0.32, hy - r*0.07), r*0.08, Color(0.8, 0.1, 0.1))
	draw_circle(Vector2(cx + r*0.32, hy - r*0.07), r*0.08, Color(0.8, 0.1, 0.1))
	_poly([Vector2(cx, hy+r*0.12), Vector2(cx-r*0.1, hy+r*0.36), Vector2(cx+r*0.1, hy+r*0.36)], Color(0.06,0.02,0.10))
	var jy = hy + r * 0.53
	draw_rect(Rect2(cx - r*0.58, jy, r*1.16, r*0.42), Color(0.78, 0.74, 0.68))
	var tw = r * 1.16 / 5.0
	for i in range(1, 5):
		draw_line(Vector2(cx - r*0.58 + tw*i, jy), Vector2(cx - r*0.58 + tw*i, jy + r*0.42), Color(0.06,0.02,0.10), 2.2)
	for dp in [[-0.2, 0.52], [0.07, 0.66], [0.3, 0.50]]:
		var bx = cx + r*dp[0]; var by = hy + r*dp[1]
		draw_line(Vector2(bx, by), Vector2(bx, by + h*0.14), Color(0.78, 0.04, 0.04, 0.88), 2.8)
		draw_circle(Vector2(bx, by + h*0.14), 4.5, Color(0.78, 0.04, 0.04, 0.88))

# ── WIN ──────────────────────────────────────────────────────────────
func _draw_win(w, h, cx, cy):
	if fate_id == "win_defeat_satan":
		draw_rect(Rect2(0,0,w,h), Color(0.25,0,0,0.5))
		_draw_satan(w, h, cx, cy)
	elif fate_id == "win_angel":
		draw_rect(Rect2(0,0,w,h), Color(0.85,0.82,0.3,0.12))
		_draw_angel(w, h, cx, cy)
	else:
		draw_rect(Rect2(0,0,w,h), Color(0.55,0.44,0,0.18))
		_draw_crown(w, h, cx, cy)

# ── COMBAT ───────────────────────────────────────────────────────────
func _draw_combat(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.28,0.08,0,0.4))
	match enemy_name:
		"Goblin":        _draw_goblin(w,h,cx,cy)
		"Specter":       _draw_specter(w,h,cx,cy)
		"Demon":         _draw_demon(w,h,cx,cy)
		"Vampire Lord":  _draw_vampire(w,h,cx,cy)
		"Ancient Dragon":_draw_dragon(w,h,cx,cy)
		"Grim Reaper":   _draw_reaper(w,h,cx,cy)
		"Satan":         _draw_satan(w,h,cx,cy)
		_:               _draw_demon(w,h,cx,cy)

# ── TRAP ─────────────────────────────────────────────────────────────
func _draw_trap(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.18,0,0.28,0.48))
	match fate_id:
		"trap_poison":   _draw_poison(w,h,cx,cy)
		"trap_curse":    _draw_curse(w,h,cx,cy)
		"trap_hellfire": _draw_hellfire_scene(w,h,cx,cy)
		"trap_void":     _draw_void(w,h,cx,cy)
		_:               _draw_poison(w,h,cx,cy)

# ── BOON ─────────────────────────────────────────────────────────────
func _draw_boon(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0,0.22,0.1,0.35))
	match fate_id:
		"boon_spring":     _draw_spring(w,h,cx,cy)
		"boon_armor":      _draw_armor(w,h,cx,cy)
		"boon_blessing":   _draw_angel(w,h,cx,cy)
		"boon_dark_pact":  _draw_imp_throne(w,h,cx,cy)
		"boon_elixir":     _draw_potion_art(w,h,cx,cy)
		_:                 _draw_spring(w,h,cx,cy)

# ── STORY ────────────────────────────────────────────────────────────
func _draw_story(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0,0.08,0.22,0.42))
	match fate_id:
		"story_wanderer":  _draw_wanderer(w,h,cx,cy)
		"story_mirror":    _draw_mirror_scene(w,h,cx,cy)
		"story_librarian": _draw_librarian(w,h,cx,cy)
		"story_child":     _draw_child_scene(w,h,cx,cy)
		"story_oracle":    _draw_oracle(w,h,cx,cy)
		_:                 _draw_wanderer(w,h,cx,cy)

func _draw_weapon(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.22,0.17,0,0.38))
	_draw_sword_art(w,h,cx,cy)

func _draw_companion(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0,0.18,0.22,0.35))
	_draw_human_silhouette(w,h,cx,cy, Color(0.3,0.8,0.6))

func _draw_item(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0,0.2,0.1,0.3))
	_draw_potion_art(w,h,cx,cy)

# ═══════════════════════════════════════════════════════════════════
# FIGURE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

func _draw_goblin(w, h, cx, cy):
	var gx = cx; var gy = cy + h*0.05
	# Ears
	_oval(Vector2(gx - h*0.22, gy - h*0.2), h*0.1, h*0.07, Color(0.28,0.45,0.10))
	_oval(Vector2(gx + h*0.22, gy - h*0.2), h*0.1, h*0.07, Color(0.28,0.45,0.10))
	# Head
	_oval(Vector2(gx, gy - h*0.2), h*0.17, h*0.16, Color(0.35,0.55,0.15))
	# Eyes
	draw_circle(Vector2(gx - h*0.06, gy - h*0.22), h*0.04, Color(0.9,0.15,0.05))
	draw_circle(Vector2(gx + h*0.06, gy - h*0.22), h*0.04, Color(0.9,0.15,0.05))
	draw_circle(Vector2(gx - h*0.06, gy - h*0.22), h*0.018, Color(1,0.9,0.8))
	draw_circle(Vector2(gx + h*0.06, gy - h*0.22), h*0.018, Color(1,0.9,0.8))
	# Grin
	draw_line(Vector2(gx-h*0.08, gy-h*0.09), Vector2(gx+h*0.08, gy-h*0.09), Color(0.08,0.04,0.02), h*0.028)
	for i in range(3):
		draw_line(Vector2(gx-h*0.055+i*h*0.055, gy-h*0.105), Vector2(gx-h*0.055+i*h*0.055, gy-h*0.078), Color(0.85,0.82,0.75), h*0.02)
	# Body
	_poly([Vector2(gx-h*0.16,gy-h*0.04), Vector2(gx+h*0.16,gy-h*0.04), Vector2(gx+h*0.2,gy+h*0.22), Vector2(gx-h*0.2,gy+h*0.22)], Color(0.28,0.42,0.10))
	# Left arm + crude blade
	draw_line(Vector2(gx-h*0.16,gy), Vector2(gx-h*0.32,gy+h*0.12), Color(0.28,0.42,0.10), h*0.06)
	_poly([Vector2(gx-h*0.28,gy+h*0.04), Vector2(gx-h*0.22,gy+h*0.2), Vector2(gx-h*0.35,gy+h*0.18)], Color(0.62,0.56,0.44))
	# Right arm
	draw_line(Vector2(gx+h*0.16,gy), Vector2(gx+h*0.3,gy+h*0.14), Color(0.28,0.42,0.10), h*0.06)
	# Legs
	draw_line(Vector2(gx-h*0.08,gy+h*0.22), Vector2(gx-h*0.12,gy+h*0.42), Color(0.28,0.42,0.10), h*0.07)
	draw_line(Vector2(gx+h*0.08,gy+h*0.22), Vector2(gx+h*0.12,gy+h*0.42), Color(0.28,0.42,0.10), h*0.07)

func _draw_specter(w, h, cx, cy):
	var sx = cx; var sy = cy - h*0.05
	var sc = Color(0.65,0.76,0.96)
	# Wispy tendrils at base
	var wisp_dx = [-0.18,-0.09,0,0.09,0.18]
	var wisp_dy = [0,h*0.08,0,h*0.08,0]
	for i in range(5):
		var wx = sx + h*wisp_dx[i]
		_poly([Vector2(wx-h*0.04,sy+h*0.28), Vector2(wx,sy+h*0.36+wisp_dy[i]), Vector2(wx+h*0.04,sy+h*0.28)], Color(sc.r,sc.g,sc.b,0.55))
	# Body
	_oval(Vector2(sx, sy+h*0.1), h*0.22, h*0.3, Color(sc.r,sc.g,sc.b,0.72))
	# Head
	_oval(Vector2(sx, sy-h*0.14), h*0.18, h*0.18, Color(sc.r,sc.g,sc.b,0.88))
	# Hollow eyes
	_oval(Vector2(sx-h*0.07,sy-h*0.16), h*0.055,h*0.065, Color(0.04,0.02,0.14,0.92))
	_oval(Vector2(sx+h*0.07,sy-h*0.16), h*0.055,h*0.065, Color(0.04,0.02,0.14,0.92))
	draw_circle(Vector2(sx-h*0.07,sy-h*0.16), h*0.025, Color(0.72,0.86,1.0,0.95))
	draw_circle(Vector2(sx+h*0.07,sy-h*0.16), h*0.025, Color(0.72,0.86,1.0,0.95))
	# Reaching hands
	_poly([Vector2(sx-h*0.22,sy+h*0.06),Vector2(sx-h*0.4,sy),Vector2(sx-h*0.42,sy+h*0.06),Vector2(sx-h*0.36,sy+h*0.12),Vector2(sx-h*0.22,sy+h*0.14)], Color(sc.r,sc.g,sc.b,0.68))
	_poly([Vector2(sx+h*0.22,sy+h*0.06),Vector2(sx+h*0.4,sy),Vector2(sx+h*0.42,sy+h*0.06),Vector2(sx+h*0.36,sy+h*0.12),Vector2(sx+h*0.22,sy+h*0.14)], Color(sc.r,sc.g,sc.b,0.68))

func _draw_demon(w, h, cx, cy):
	var dx2 = cx; var dy = cy - h*0.02
	var dc = Color(0.72,0.1,0.08)
	# Horns
	_poly([Vector2(dx2-h*0.1,dy-h*0.32), Vector2(dx2-h*0.18,dy-h*0.52), Vector2(dx2-h*0.04,dy-h*0.34)], Color(0.45,0.06,0.05))
	_poly([Vector2(dx2+h*0.1,dy-h*0.32), Vector2(dx2+h*0.18,dy-h*0.52), Vector2(dx2+h*0.04,dy-h*0.34)], Color(0.45,0.06,0.05))
	# Head
	_oval(Vector2(dx2,dy-h*0.28), h*0.16,h*0.15, dc)
	# Glowing eyes
	draw_circle(Vector2(dx2-h*0.06,dy-h*0.3), h*0.038, Color(1,0.85,0.1))
	draw_circle(Vector2(dx2+h*0.06,dy-h*0.3), h*0.038, Color(1,0.85,0.1))
	draw_circle(Vector2(dx2-h*0.06,dy-h*0.3), h*0.018, Color(0.05,0.02,0.0))
	draw_circle(Vector2(dx2+h*0.06,dy-h*0.3), h*0.018, Color(0.05,0.02,0.0))
	# Muscular body (trapezoid wider at shoulders)
	_poly([Vector2(dx2-h*0.22,dy-h*0.13), Vector2(dx2+h*0.22,dy-h*0.13), Vector2(dx2+h*0.16,dy+h*0.22), Vector2(dx2-h*0.16,dy+h*0.22)], Color(0.58,0.08,0.06))
	# Arms (thick)
	draw_line(Vector2(dx2-h*0.22,dy-h*0.1), Vector2(dx2-h*0.36,dy+h*0.08), dc, h*0.08)
	draw_line(Vector2(dx2+h*0.22,dy-h*0.1), Vector2(dx2+h*0.36,dy+h*0.08), dc, h*0.08)
	# Claws
	for i in range(3):
		draw_line(Vector2(dx2-h*0.36,dy+h*0.08), Vector2(dx2-h*(0.4-i*0.04),dy+h*0.18), Color(0.88,0.7,0.5), h*0.02)
		draw_line(Vector2(dx2+h*0.36,dy+h*0.08), Vector2(dx2+h*(0.4-i*0.04),dy+h*0.18), Color(0.88,0.7,0.5), h*0.02)
	# Legs
	draw_line(Vector2(dx2-h*0.1,dy+h*0.22), Vector2(dx2-h*0.14,dy+h*0.44), dc, h*0.09)
	draw_line(Vector2(dx2+h*0.1,dy+h*0.22), Vector2(dx2+h*0.14,dy+h*0.44), dc, h*0.09)
	# Tail
	draw_line(Vector2(dx2+h*0.14,dy+h*0.3), Vector2(dx2+h*0.32,dy+h*0.42), dc, h*0.03)
	_poly([Vector2(dx2+h*0.32,dy+h*0.42), Vector2(dx2+h*0.4,dy+h*0.36), Vector2(dx2+h*0.38,dy+h*0.46)], Color(0.6,0.08,0.06))

func _draw_vampire(w, h, cx, cy):
	var vx = cx; var vy = cy - h*0.05
	# Cape spread wide
	_poly([Vector2(vx,vy-h*0.1), Vector2(vx-w*0.42,vy+h*0.45), Vector2(vx-w*0.1,vy+h*0.1)], Color(0.08,0.04,0.14))
	_poly([Vector2(vx,vy-h*0.1), Vector2(vx+w*0.42,vy+h*0.45), Vector2(vx+w*0.1,vy+h*0.1)], Color(0.08,0.04,0.14))
	# Cape inner
	_poly([Vector2(vx,vy-h*0.1), Vector2(vx-w*0.32,vy+h*0.45), Vector2(vx-w*0.06,vy+h*0.12)], Color(0.18,0.04,0.08))
	_poly([Vector2(vx,vy-h*0.1), Vector2(vx+w*0.32,vy+h*0.45), Vector2(vx+w*0.06,vy+h*0.12)], Color(0.18,0.04,0.08))
	# Slender body
	_poly([Vector2(vx-h*0.09,vy-h*0.1), Vector2(vx+h*0.09,vy-h*0.1), Vector2(vx+h*0.07,vy+h*0.3), Vector2(vx-h*0.07,vy+h*0.3)], Color(0.12,0.06,0.18))
	# Pale head
	_oval(Vector2(vx, vy-h*0.24), h*0.13, h*0.14, Color(0.82,0.78,0.74))
	# Eyes — red
	draw_circle(Vector2(vx-h*0.05,vy-h*0.26), h*0.035, Color(0.88,0.12,0.08))
	draw_circle(Vector2(vx+h*0.05,vy-h*0.26), h*0.035, Color(0.88,0.12,0.08))
	draw_circle(Vector2(vx-h*0.05,vy-h*0.26), h*0.015, Color(0.05,0.02,0.05))
	draw_circle(Vector2(vx+h*0.05,vy-h*0.26), h*0.015, Color(0.05,0.02,0.05))
	# Fangs
	_poly([Vector2(vx-h*0.028,vy-h*0.14), Vector2(vx-h*0.018,vy-h*0.08), Vector2(vx-h*0.008,vy-h*0.14)], Color(0.9,0.88,0.85))
	_poly([Vector2(vx+h*0.008,vy-h*0.14), Vector2(vx+h*0.018,vy-h*0.08), Vector2(vx+h*0.028,vy-h*0.14)], Color(0.9,0.88,0.85))

func _draw_dragon(w, h, cx, cy):
	var dc = Color(0.14,0.28,0.12)
	var dh = Color(0.22,0.38,0.18)
	# Left wing
	_poly([Vector2(cx-h*0.12,cy-h*0.05), Vector2(w*0.04,cy-h*0.44), Vector2(w*0.12,cy+h*0.18), Vector2(cx-h*0.08,cy+h*0.1)], dc)
	draw_line(Vector2(cx-h*0.12,cy-h*0.05), Vector2(w*0.04,cy-h*0.44), dh, 1.8)
	draw_line(Vector2(cx-h*0.12,cy-h*0.05), Vector2(w*0.16,cy-h*0.34), dh, 1.5)
	# Right wing
	_poly([Vector2(cx+h*0.12,cy-h*0.05), Vector2(w*0.96,cy-h*0.44), Vector2(w*0.88,cy+h*0.18), Vector2(cx+h*0.08,cy+h*0.1)], dc)
	draw_line(Vector2(cx+h*0.12,cy-h*0.05), Vector2(w*0.96,cy-h*0.44), dh, 1.8)
	draw_line(Vector2(cx+h*0.12,cy-h*0.05), Vector2(w*0.84,cy-h*0.34), dh, 1.5)
	# Body
	_oval(Vector2(cx, cy+h*0.08), h*0.22, h*0.18, dh)
	# Neck
	_poly([Vector2(cx-h*0.08,cy-h*0.04), Vector2(cx-h*0.04,cy-h*0.04), Vector2(cx-h*0.18,cy-h*0.36), Vector2(cx-h*0.26,cy-h*0.33)], dh)
	# Head
	_poly([Vector2(cx-h*0.26,cy-h*0.33), Vector2(cx-h*0.17,cy-h*0.47), Vector2(cx-h*0.07,cy-h*0.43), Vector2(cx,cy-h*0.31), Vector2(cx-h*0.16,cy-h*0.27)], dh)
	# Horn
	_poly([Vector2(cx-h*0.17,cy-h*0.47), Vector2(cx-h*0.21,cy-h*0.56), Vector2(cx-h*0.13,cy-h*0.47)], dc)
	# Eye
	draw_circle(Vector2(cx-h*0.2,cy-h*0.4), h*0.026, Color(0.9,0.6,0.1))
	draw_circle(Vector2(cx-h*0.2,cy-h*0.4), h*0.012, Color(0.05,0.02,0.02))
	# Fire breath
	_poly([Vector2(cx-h*0.04,cy-h*0.35), Vector2(cx+h*0.12,cy-h*0.32), Vector2(cx+h*0.08,cy-h*0.28), Vector2(cx-h*0.04,cy-h*0.31)], Color(0.9,0.55,0.1,0.88))
	_poly([Vector2(cx+h*0.06,cy-h*0.34), Vector2(cx+h*0.18,cy-h*0.3), Vector2(cx+h*0.14,cy-h*0.27)], Color(1,0.88,0.2,0.9))
	# Tail
	for i in range(5):
		var t = float(i)/4.0
		draw_circle(Vector2(cx+h*0.2+h*0.12*t, cy+h*0.12+h*0.24*t), h*0.045*(1.0-t*0.55), dh)

func _draw_reaper(w, h, cx, cy):
	var rx = cx; var ry = cy - h*0.02
	# Robe (large dark triangle)
	_poly([Vector2(rx-h*0.22,ry-h*0.1), Vector2(rx+h*0.22,ry-h*0.1), Vector2(rx+h*0.3,ry+h*0.44), Vector2(rx-h*0.3,ry+h*0.44)], Color(0.06,0.04,0.10))
	# Hood
	_oval(Vector2(rx, ry-h*0.22), h*0.18, h*0.22, Color(0.08,0.05,0.12))
	# Skull in hood shadow
	_oval(Vector2(rx, ry-h*0.22), h*0.11, h*0.11, Color(0.72,0.70,0.66))
	_oval(Vector2(rx-h*0.04,ry-h*0.24), h*0.035,h*0.04, Color(0.04,0.02,0.08))
	_oval(Vector2(rx+h*0.04,ry-h*0.24), h*0.035,h*0.04, Color(0.04,0.02,0.08))
	# Bony hands
	draw_line(Vector2(rx-h*0.22,ry-h*0.02), Vector2(rx-h*0.38,ry+h*0.08), Color(0.7,0.68,0.62), h*0.03)
	draw_line(Vector2(rx+h*0.22,ry-h*0.02), Vector2(rx+h*0.38,ry+h*0.08), Color(0.7,0.68,0.62), h*0.03)
	# Scythe handle (long diagonal)
	draw_line(Vector2(rx+h*0.36,ry+h*0.1), Vector2(rx-h*0.18,ry-h*0.48), Color(0.45,0.35,0.2), h*0.025)
	# Scythe blade (curved crescent)
	for i in range(8):
		var t = float(i)/7.0
		var ang = PI * 0.6 + t * PI * 0.7
		var bx = rx - h*0.18 + cos(ang)*h*0.22
		var by = ry - h*0.48 + sin(ang)*h*0.22
		if i > 0:
			var pa = PI * 0.6 + float(i-1)/7.0 * PI * 0.7
			draw_line(Vector2(rx-h*0.18+cos(pa)*h*0.22, ry-h*0.48+sin(pa)*h*0.22),
					  Vector2(bx,by), Color(0.72,0.68,0.62), h*0.03)

func _draw_satan(w, h, cx, cy):
	var sx = cx; var sy = cy - h*0.04
	# Massive wings
	_poly([Vector2(sx-h*0.15,sy-h*0.1), Vector2(w*0.02,sy-h*0.48), Vector2(w*0.08,sy+h*0.3), Vector2(sx-h*0.12,sy+h*0.14)], Color(0.4,0.04,0.04))
	_poly([Vector2(sx+h*0.15,sy-h*0.1), Vector2(w*0.98,sy-h*0.48), Vector2(w*0.92,sy+h*0.3), Vector2(sx+h*0.12,sy+h*0.14)], Color(0.4,0.04,0.04))
	draw_line(Vector2(sx-h*0.15,sy-h*0.1), Vector2(w*0.02,sy-h*0.48), Color(0.65,0.1,0.08), 2)
	draw_line(Vector2(sx+h*0.15,sy-h*0.1), Vector2(w*0.98,sy-h*0.48), Color(0.65,0.1,0.08), 2)
	# Horns (large)
	_poly([Vector2(sx-h*0.12,sy-h*0.36), Vector2(sx-h*0.24,sy-h*0.58), Vector2(sx-h*0.04,sy-h*0.38)], Color(0.35,0.04,0.04))
	_poly([Vector2(sx+h*0.12,sy-h*0.36), Vector2(sx+h*0.24,sy-h*0.58), Vector2(sx+h*0.04,sy-h*0.38)], Color(0.35,0.04,0.04))
	# Head
	_oval(Vector2(sx, sy-h*0.28), h*0.18, h*0.18, Color(0.68,0.1,0.08))
	# Glowing eyes
	draw_circle(Vector2(sx-h*0.07,sy-h*0.3), h*0.04, Color(1,0.88,0.1))
	draw_circle(Vector2(sx+h*0.07,sy-h*0.3), h*0.04, Color(1,0.88,0.1))
	draw_circle(Vector2(sx-h*0.07,sy-h*0.3), h*0.016, Color(0.02,0.01,0))
	draw_circle(Vector2(sx+h*0.07,sy-h*0.3), h*0.016, Color(0.02,0.01,0))
	# Massive body
	_poly([Vector2(sx-h*0.26,sy-h*0.1), Vector2(sx+h*0.26,sy-h*0.1), Vector2(sx+h*0.2,sy+h*0.28), Vector2(sx-h*0.2,sy+h*0.28)], Color(0.5,0.06,0.06))
	# Arms
	draw_line(Vector2(sx-h*0.26,sy-h*0.06), Vector2(sx-h*0.42,sy+h*0.1), Color(0.68,0.1,0.08), h*0.09)
	draw_line(Vector2(sx+h*0.26,sy-h*0.06), Vector2(sx+h*0.42,sy+h*0.1), Color(0.68,0.1,0.08), h*0.09)
	# Fire at feet
	for i in range(5):
		var fx = sx - h*0.22 + i*h*0.11
		_poly([Vector2(fx-h*0.045,sy+h*0.28), Vector2(fx,sy+h*0.1+i*h*0.04), Vector2(fx+h*0.045,sy+h*0.28)], Color(0.9,0.45+i*0.05,0.05,0.85))

func _draw_angel(w, h, cx, cy):
	var ax = cx; var ay = cy - h*0.04
	# Wing glow
	_oval(Vector2(ax, ay), w*0.36, h*0.44, Color(1,0.95,0.7,0.12))
	# Wings
	_poly([Vector2(ax,ay-h*0.1), Vector2(ax-w*0.4,ay-h*0.3), Vector2(ax-w*0.38,ay+h*0.2), Vector2(ax-h*0.12,ay+h*0.06)], Color(0.92,0.90,0.82))
	_poly([Vector2(ax,ay-h*0.1), Vector2(ax+w*0.4,ay-h*0.3), Vector2(ax+w*0.38,ay+h*0.2), Vector2(ax+h*0.12,ay+h*0.06)], Color(0.92,0.90,0.82))
	# Wing feather detail lines
	for i in range(4):
		var t = float(i)/3.0
		draw_line(Vector2(ax-h*0.1,ay-h*0.06+t*h*0.12), Vector2(ax-w*0.35+t*w*0.08,ay-h*0.22+t*h*0.36), Color(0.78,0.75,0.65,0.5), 1.2)
		draw_line(Vector2(ax+h*0.1,ay-h*0.06+t*h*0.12), Vector2(ax+w*0.35-t*w*0.08,ay-h*0.22+t*h*0.36), Color(0.78,0.75,0.65,0.5), 1.2)
	# Body
	_poly([Vector2(ax-h*0.1,ay-h*0.1), Vector2(ax+h*0.1,ay-h*0.1), Vector2(ax+h*0.08,ay+h*0.3), Vector2(ax-h*0.08,ay+h*0.3)], Color(0.92,0.88,0.78))
	# Head
	_oval(Vector2(ax, ay-h*0.24), h*0.13, h*0.14, Color(0.92,0.86,0.76))
	# Halo
	draw_arc(Vector2(ax, ay-h*0.37), h*0.14, 0, TAU, 32, Color(1,0.92,0.4,0.9), h*0.018)
	draw_arc(Vector2(ax, ay-h*0.37), h*0.14, 0, TAU, 32, Color(1,0.85,0.2,0.3), h*0.032)

func _draw_crown(w, h, cx, cy):
	var gcy = cy + h*0.06
	# Velvet base / cushion
	_oval(Vector2(cx, gcy+h*0.2), h*0.28, h*0.07, Color(0.45,0.06,0.12))
	# Crown base
	draw_rect(Rect2(cx-h*0.25, gcy-h*0.05, h*0.5, h*0.2), Color(0.8,0.62,0.1))
	# Crown points (5)
	var pts_x = [-0.25,-0.125,0,0.125,0.25]
	var pts_ht = [0.32,0.22,0.36,0.22,0.32]
	for i in range(4):
		_poly([
			Vector2(cx+h*pts_x[i], gcy-h*0.05),
			Vector2(cx+h*(pts_x[i]+pts_x[i+1])*0.5, gcy-h*pts_ht[i]),
			Vector2(cx+h*pts_x[i+1], gcy-h*0.05),
		], Color(0.8,0.62,0.1))
	_poly([Vector2(cx-h*0.02,gcy-h*0.05),Vector2(cx,gcy-h*0.36),Vector2(cx+h*0.02,gcy-h*0.05)], Color(0.88,0.7,0.14))
	# Gems
	for gx2 in [cx-h*0.15, cx, cx+h*0.15]:
		draw_circle(Vector2(gx2, gcy+h*0.06), h*0.044, Color(0.8,0.12,0.12))
		draw_circle(Vector2(gx2, gcy+h*0.06), h*0.024, Color(1,0.5,0.5))
	# Gold glow
	_oval(Vector2(cx,gcy-h*0.05), h*0.3, h*0.22, Color(0.95,0.78,0.2,0.1))

func _draw_poison(w, h, cx, cy):
	var pc = Color(0.2,0.72,0.15)
	# Cloud blobs
	for blob in [[0,-0.14,0.22,0.18],[- 0.22,-0.04,0.18,0.16],[0.22,-0.04,0.18,0.16],[0,0.06,0.2,0.14],[-0.16,0.04,0.16,0.14],[0.16,0.04,0.16,0.14]]:
		_oval(Vector2(cx+blob[0]*h, cy+blob[1]*h), blob[2]*h, blob[3]*h, Color(pc.r,pc.g,pc.b,0.72))
	# Skull in cloud
	_oval(Vector2(cx,cy-h*0.08), h*0.12,h*0.12, Color(0.82,0.8,0.72))
	_oval(Vector2(cx-h*0.046,cy-h*0.1), h*0.034,h*0.038, Color(0.1,0.06,0.04))
	_oval(Vector2(cx+h*0.046,cy-h*0.1), h*0.034,h*0.038, Color(0.1,0.06,0.04))
	draw_rect(Rect2(cx-h*0.08,cy-h*0.04,h*0.16,h*0.06), Color(0.82,0.8,0.72))
	# Drips
	for ddx in [-0.06,0,0.06]:
		draw_line(Vector2(cx+ddx*h, cy+h*0.12), Vector2(cx+ddx*h, cy+h*0.28), Color(pc.r,pc.g,pc.b,0.78), 3)
		draw_circle(Vector2(cx+ddx*h, cy+h*0.28), 5, Color(pc.r,pc.g,pc.b,0.78))

func _draw_curse(w, h, cx, cy):
	# Pentagram-ish sigil
	var r = h * 0.34
	var pts2: Array = []
	for i in range(5):
		var a = -PI/2 + TAU * i / 5
		pts2.append(Vector2(cx + cos(a)*r, cy + sin(a)*r))
	# Star lines
	for i in range(5):
		draw_line(pts2[i], pts2[(i+2)%5], Color(0.8,0.05,0.05,0.85), 2.2)
	# Circle outline
	draw_arc(Vector2(cx,cy), r, 0, TAU, 48, Color(0.75,0.04,0.04,0.7), 1.5)
	draw_arc(Vector2(cx,cy), r*0.96, 0, TAU, 48, Color(0.75,0.04,0.04,0.3), 1.0)
	# Eye in center
	_oval(Vector2(cx,cy), h*0.08, h*0.06, Color(0.12,0.04,0.18))
	_oval(Vector2(cx,cy), h*0.045, h*0.055, Color(0.7,0.04,0.04))
	draw_circle(Vector2(cx,cy), h*0.02, Color(1,0.9,0.8))

func _draw_hellfire_scene(w, h, cx, cy):
	# Multiple fire columns across base
	var fire_base = h * 0.9
	for i in range(5):
		var fx = w * (0.1 + i*0.2)
		var fh = h * (0.48 + [0,0.12,0.04,0.08,0][i])
		var fw = w * 0.1
		_poly([Vector2(fx-fw*0.5,fire_base), Vector2(fx-fw*0.22,fire_base-fh*0.55), Vector2(fx,fire_base-fh), Vector2(fx+fw*0.22,fire_base-fh*0.55), Vector2(fx+fw*0.5,fire_base)], Color(0.88,0.38,0.04,0.9))
		_poly([Vector2(fx-fw*0.25,fire_base), Vector2(fx-fw*0.1,fire_base-fh*0.5), Vector2(fx,fire_base-fh*0.84), Vector2(fx+fw*0.1,fire_base-fh*0.5), Vector2(fx+fw*0.25,fire_base)], Color(1,0.82,0.2,0.88))
	# Ground glow
	draw_rect(Rect2(0, h*0.85, w, h*0.15), Color(0.7,0.22,0,0.45))

func _draw_void(w, h, cx, cy):
	# Swirling dark portal
	for ring in range(8, 0, -1):
		var rf = float(ring)/8.0
		_oval(Vector2(cx,cy), h*0.4*rf, h*0.38*rf, Color(0.12*rf, 0.0, 0.22*rf, 0.85))
	# Spiral arms (bright edges)
	for i in range(12):
		var a = TAU*i/12 + 0.4
		var r2 = h*0.12 + h*0.28*(float(i)/11.0)
		var ex = cx+cos(a)*r2; var ey = cy+sin(a)*r2*0.95
		draw_circle(Vector2(ex,ey), h*0.018, Color(0.6,0.2,0.9,0.6))
	# Center black hole
	draw_circle(Vector2(cx,cy), h*0.1, Color(0.01,0,0.02))
	draw_arc(Vector2(cx,cy), h*0.1, 0, TAU, 32, Color(0.5,0.15,0.8,0.7), 2.0)
	# Stars being sucked in
	for st in [[0.38,0.18],[0.55,0.58],[0.22,0.72],[0.72,0.22],[0.68,0.76]]:
		draw_circle(Vector2(w*st[0],h*st[1]), 2.5, Color(0.8,0.7,0.95,0.72))

func _draw_spring(w, h, cx, cy):
	# Glowing pool
	_oval(Vector2(cx,cy+h*0.12), h*0.32, h*0.14, Color(0.45,0.82,0.95,0.55))
	_oval(Vector2(cx,cy+h*0.12), h*0.28, h*0.11, Color(0.6,0.9,1.0,0.75))
	# Light ripples
	for r2 in [h*0.08, h*0.16, h*0.24]:
		draw_arc(Vector2(cx,cy+h*0.12), r2, 0, TAU, 24, Color(0.8,0.95,1.0,0.35), 1.2)
	# Light rays up from pool
	for i in range(6):
		var a = -PI*0.8 + i*PI*0.32
		var ray_len = h*(0.3+i*0.05)
		if i > 3: ray_len = h*(0.3+(5-i)*0.05)
		draw_line(Vector2(cx,cy+h*0.1), Vector2(cx+cos(a)*ray_len, cy+h*0.1+sin(a)*ray_len), Color(0.75,0.95,1.0,0.35-(abs(i-2.5)*0.04)), 1.5)
	# Shimmer dots
	for sd in [[0,0.02],[0.18,0.06],[-0.18,0.06],[0.1,-0.02],[-0.1,-0.02]]:
		draw_circle(Vector2(cx+sd[0]*h, cy+h*0.12+sd[1]*h), 3.5, Color(0.9,0.98,1.0,0.85))

func _draw_armor(w, h, cx, cy):
	var ac = Color(0.62,0.60,0.58)
	var al = Color(0.82,0.80,0.76)
	# Helmet
	_oval(Vector2(cx,cy-h*0.32), h*0.16, h*0.12, ac)
	draw_rect(Rect2(cx-h*0.14,cy-h*0.32,h*0.28,h*0.1), ac)
	# Visor slit
	draw_rect(Rect2(cx-h*0.1,cy-h*0.3,h*0.2,h*0.028), Color(0.08,0.06,0.1))
	# Gorget
	_poly([Vector2(cx-h*0.1,cy-h*0.2),Vector2(cx+h*0.1,cy-h*0.2),Vector2(cx+h*0.12,cy-h*0.12),Vector2(cx-h*0.12,cy-h*0.12)], Color(0.5,0.48,0.46))
	# Breastplate
	_poly([Vector2(cx-h*0.22,cy-h*0.12),Vector2(cx+h*0.22,cy-h*0.12),Vector2(cx+h*0.26,cy+h*0.18),Vector2(cx-h*0.26,cy+h*0.18)], ac)
	# Center ridge line
	draw_line(Vector2(cx,cy-h*0.12), Vector2(cx,cy+h*0.18), Color(0.5,0.48,0.46), 2.0)
	# Shoulder pauldrons
	_oval(Vector2(cx-h*0.28,cy-h*0.08), h*0.1, h*0.07, ac)
	_oval(Vector2(cx+h*0.28,cy-h*0.08), h*0.1, h*0.07, ac)
	# Highlight gleam
	draw_line(Vector2(cx-h*0.1,cy-h*0.1), Vector2(cx-h*0.04,cy), al, 2.2)

func _draw_imp_throne(w, h, cx, cy):
	# Throne of bones
	draw_rect(Rect2(cx-h*0.24,cy-h*0.18,h*0.48,h*0.52), Color(0.3,0.24,0.18))
	for bx2 in [cx-h*0.22, cx+h*0.16]:
		for i in range(3):
			draw_circle(Vector2(bx2, cy-h*0.18+i*h*0.15), h*0.04, Color(0.72,0.70,0.64))
	# Small imp
	_oval(Vector2(cx,cy-h*0.16), h*0.1,h*0.1, Color(0.38,0.22,0.38))
	draw_circle(Vector2(cx-h*0.04,cy-h*0.18), h*0.025, Color(0.85,0.55,0.1))
	draw_circle(Vector2(cx+h*0.04,cy-h*0.18), h*0.025, Color(0.85,0.55,0.1))
	_poly([Vector2(cx-h*0.08,cy-h*0.1),Vector2(cx+h*0.08,cy-h*0.1),Vector2(cx+h*0.06,cy+h*0.04),Vector2(cx-h*0.06,cy+h*0.04)], Color(0.3,0.18,0.3))
	# Grin
	draw_arc(Vector2(cx,cy-h*0.1), h*0.04, PI*0.15, PI*0.85, 10, Color(0.9,0.82,0.72), h*0.018)
	# Little tail
	draw_line(Vector2(cx+h*0.06,cy+h*0.02), Vector2(cx+h*0.14,cy+h*0.1), Color(0.38,0.22,0.38), h*0.02)
	_poly([Vector2(cx+h*0.14,cy+h*0.1),Vector2(cx+h*0.2,cy+h*0.06),Vector2(cx+h*0.18,cy+h*0.14)], Color(0.38,0.22,0.38))
	# Extended hand
	draw_line(Vector2(cx+h*0.08,cy-h*0.07), Vector2(cx+h*0.2,cy-h*0.12), Color(0.38,0.22,0.38), h*0.04)

func _draw_potion_art(w, h, cx, cy):
	var pc2 = Color(0.18,0.78,0.35)
	# Bottle body
	_poly([Vector2(cx-h*0.16,cy-h*0.05),Vector2(cx+h*0.16,cy-h*0.05),Vector2(cx+h*0.2,cy+h*0.28),Vector2(cx-h*0.2,cy+h*0.28)], Color(0.12,0.38,0.2,0.88))
	_oval(Vector2(cx,cy+h*0.28), h*0.2,h*0.07, Color(0.12,0.38,0.2,0.88))
	# Liquid glow
	_oval(Vector2(cx,cy+h*0.18), h*0.16,h*0.12, Color(pc2.r,pc2.g,pc2.b,0.7))
	# Neck
	draw_rect(Rect2(cx-h*0.07,cy-h*0.2,h*0.14,h*0.16), Color(0.12,0.32,0.18,0.88))
	# Cork
	draw_rect(Rect2(cx-h*0.07,cy-h*0.25,h*0.14,h*0.065), Color(0.55,0.38,0.2))
	# Shine
	_poly([Vector2(cx-h*0.06,cy),Vector2(cx-h*0.02,cy-h*0.1),Vector2(cx,cy)], Color(0.6,0.95,0.7,0.55))
	# Bubbles
	for bbl in [[-0.06,0.12,0.028],[0.05,0.2,0.022],[-0.02,0.28,0.018]]:
		draw_circle(Vector2(cx+bbl[0]*h,cy+bbl[1]*h), bbl[2]*h, Color(0.7,1.0,0.8,0.5))
	# Glow aura
	_oval(Vector2(cx,cy+h*0.14), h*0.25,h*0.24, Color(pc2.r,pc2.g,pc2.b,0.1))

func _draw_wanderer(w, h, cx, cy):
	var wc = Color(0.38,0.42,0.52)
	# Small fire
	_poly([Vector2(cx-h*0.28,cy+h*0.35),Vector2(cx-h*0.24,cy+h*0.18),Vector2(cx-h*0.2,cy+h*0.35)], Color(0.88,0.48,0.08,0.85))
	_poly([Vector2(cx-h*0.27,cy+h*0.35),Vector2(cx-h*0.24,cy+h*0.24),Vector2(cx-h*0.21,cy+h*0.35)], Color(1,0.78,0.2,0.8))
	# Cloak
	_poly([Vector2(cx,cy-h*0.28),Vector2(cx-h*0.22,cy+h*0.42),Vector2(cx+h*0.22,cy+h*0.42)], wc)
	# Hood outline
	_oval(Vector2(cx,cy-h*0.26), h*0.17,h*0.2, Color(wc.r*0.7,wc.g*0.7,wc.b*0.7))
	_oval(Vector2(cx,cy-h*0.26), h*0.13,h*0.14, Color(0.2,0.16,0.12))
	# Face barely visible
	_oval(Vector2(cx,cy-h*0.28), h*0.08,h*0.08, Color(0.55,0.48,0.4))
	# Staff
	draw_line(Vector2(cx+h*0.2,cy-h*0.18), Vector2(cx+h*0.14,cy+h*0.44), Color(0.45,0.32,0.18), h*0.025)
	draw_circle(Vector2(cx+h*0.2,cy-h*0.18), h*0.03, Color(0.6,0.55,0.3))
	# Fire glow on figure
	draw_rect(Rect2(cx-h*0.35,cy+h*0.3,h*0.2,h*0.1), Color(0.9,0.5,0.1,0.12))

func _draw_mirror_scene(w, h, cx, cy):
	# Frame
	draw_rect(Rect2(cx-h*0.24,cy-h*0.4,h*0.48,h*0.72), Color(0.45,0.32,0.14))
	draw_rect(Rect2(cx-h*0.19,cy-h*0.35,h*0.38,h*0.62), Color(0.04,0.08,0.14,0.88))
	# Ornate corners
	for fx2 in [cx-h*0.24, cx+h*0.24]:
		for fy2 in [cy-h*0.4, cy+h*0.32]:
			draw_circle(Vector2(fx2,fy2), h*0.04, Color(0.65,0.5,0.22))
	# Reflection (slightly off)
	_draw_human_silhouette(h*0.1, h*0.36, cx-h*0.05, cy-h*0.1, Color(0.55,0.48,0.62,0.72))
	# Eerie glow
	_oval(Vector2(cx,cy-h*0.04), h*0.16,h*0.22, Color(0.4,0.35,0.55,0.18))

func _draw_librarian(w, h, cx, cy):
	# Skeleton sitting, reading book
	var lx = cx; var ly = cy - h*0.05
	# Ribs / torso
	draw_rect(Rect2(lx-h*0.1,ly-h*0.06,h*0.2,h*0.28), Color(0.72,0.70,0.64,0.8))
	for i in range(4):
		draw_line(Vector2(lx-h*0.1,ly-h*0.02+i*h*0.07), Vector2(lx+h*0.1,ly-h*0.02+i*h*0.07), Color(0.12,0.08,0.12), 1.5)
	# Skull
	_oval(Vector2(lx,ly-h*0.2), h*0.13,h*0.13, Color(0.78,0.76,0.70))
	_oval(Vector2(lx-h*0.045,ly-h*0.22), h*0.034,h*0.038, Color(0.08,0.05,0.12))
	_oval(Vector2(lx+h*0.045,ly-h*0.22), h*0.034,h*0.038, Color(0.08,0.05,0.12))
	# Arms holding book
	draw_line(Vector2(lx-h*0.1,ly-h*0.02), Vector2(lx-h*0.24,ly+h*0.18), Color(0.72,0.70,0.64), h*0.04)
	draw_line(Vector2(lx+h*0.1,ly-h*0.02), Vector2(lx+h*0.24,ly+h*0.18), Color(0.72,0.70,0.64), h*0.04)
	# Book
	_poly([Vector2(lx-h*0.24,ly+h*0.12),Vector2(lx+h*0.24,ly+h*0.12),Vector2(lx+h*0.26,ly+h*0.3),Vector2(lx-h*0.26,ly+h*0.3)], Color(0.28,0.2,0.12))
	draw_line(Vector2(lx,ly+h*0.12), Vector2(lx,ly+h*0.3), Color(0.2,0.14,0.08), 1.5)
	# Candle
	draw_line(Vector2(lx+h*0.32,ly+h*0.28), Vector2(lx+h*0.32,ly-h*0.06), Color(0.82,0.78,0.68), h*0.025)
	_poly([Vector2(lx+h*0.3,ly-h*0.06),Vector2(lx+h*0.32,ly-h*0.18),Vector2(lx+h*0.34,ly-h*0.06)], Color(0.9,0.72,0.2,0.88))
	draw_circle(Vector2(lx+h*0.32,ly-h*0.06), h*0.035, Color(0.9,0.72,0.2,0.18))

func _draw_child_scene(w, h, cx, cy):
	var chx = cx + h*0.04; var chy = cy - h*0.05
	# Child sitting, small
	_oval(Vector2(chx,chy-h*0.22), h*0.1,h*0.1, Color(0.72,0.62,0.52))
	# Body
	_poly([Vector2(chx-h*0.08,chy-h*0.12),Vector2(chx+h*0.08,chy-h*0.12),Vector2(chx+h*0.08,chy+h*0.12),Vector2(chx-h*0.08,chy+h*0.12)], Color(0.52,0.44,0.62))
	# Legs crossed on floor
	draw_line(Vector2(chx-h*0.08,chy+h*0.12), Vector2(chx-h*0.18,chy+h*0.28), Color(0.52,0.44,0.62), h*0.055)
	draw_line(Vector2(chx+h*0.08,chy+h*0.12), Vector2(chx+h*0.18,chy+h*0.28), Color(0.52,0.44,0.62), h*0.055)
	# Arm drawing
	draw_line(Vector2(chx-h*0.08,chy-h*0.04), Vector2(chx-h*0.22,chy+h*0.12), Color(0.72,0.62,0.52), h*0.04)
	# Floor drawings (rough circles representing you)
	draw_arc(Vector2(cx-h*0.22,cy+h*0.3), h*0.06, 0, TAU, 16, Color(0.4,0.35,0.28,0.75), 1.5)
	draw_arc(Vector2(cx+h*0.08,cy+h*0.36), h*0.04, 0, TAU, 12, Color(0.4,0.35,0.28,0.75), 1.5)
	# Chalk
	draw_line(Vector2(chx-h*0.22,chy+h*0.12), Vector2(cx-h*0.28,cy+h*0.3), Color(0.75,0.72,0.68), h*0.018)

func _draw_oracle(w, h, cx, cy):
	# White-robed figure facing away, arms slightly raised
	var ox = cx; var oy = cy - h*0.04
	# Robe
	_poly([Vector2(ox-h*0.16,oy-h*0.08),Vector2(ox+h*0.16,oy-h*0.08),Vector2(ox+h*0.24,oy+h*0.42),Vector2(ox-h*0.24,oy+h*0.42)], Color(0.86,0.84,0.82))
	# Head (back of head)
	_oval(Vector2(ox,oy-h*0.22), h*0.13,h*0.14, Color(0.82,0.78,0.74))
	# Raised arms
	_poly([Vector2(ox-h*0.16,oy-h*0.04),Vector2(ox-h*0.1,oy-h*0.1),Vector2(ox-h*0.36,oy-h*0.24),Vector2(ox-h*0.3,oy-h*0.16)], Color(0.86,0.84,0.82))
	_poly([Vector2(ox+h*0.16,oy-h*0.04),Vector2(ox+h*0.1,oy-h*0.1),Vector2(ox+h*0.36,oy-h*0.24),Vector2(ox+h*0.3,oy-h*0.16)], Color(0.86,0.84,0.82))
	# Mystic glow behind
	_oval(Vector2(ox,oy-h*0.04), h*0.34,h*0.4, Color(0.78,0.72,0.92,0.1))
	# Symbol floating above hands
	draw_arc(Vector2(ox,oy-h*0.38), h*0.1, 0, TAU, 24, Color(0.72,0.65,0.88,0.65), 1.8)
	draw_line(Vector2(ox,oy-h*0.48), Vector2(ox,oy-h*0.28), Color(0.72,0.65,0.88,0.5), 1.5)
	draw_line(Vector2(ox-h*0.1,oy-h*0.38), Vector2(ox+h*0.1,oy-h*0.38), Color(0.72,0.65,0.88,0.5), 1.5)

func _draw_sword_art(w, h, cx, cy):
	# Diagonal glowing sword
	var a1 = Vector2(cx-h*0.18, cy+h*0.38)
	var a2 = Vector2(cx+h*0.18, cy-h*0.38)
	# Blade glow
	draw_line(a1, a2, Color(0.9,0.75,0.2,0.22), h*0.08)
	draw_line(a1, a2, Color(0.95,0.85,0.3,0.35), h*0.045)
	# Blade
	draw_line(a1, a2, Color(0.82,0.80,0.75), h*0.02)
	draw_line(a1, a2, Color(0.96,0.94,0.88), h*0.008)
	# Cross guard
	var mid2 = (a1 + a2) * 0.5 + Vector2(h*0.02,h*0.02)
	var perp = Vector2(a2.y-a1.y, -(a2.x-a1.x)).normalized() * h*0.14
	draw_line(mid2 - perp, mid2 + perp, Color(0.8,0.62,0.12), h*0.025)
	# Handle
	var htop = mid2 + (a1-a2).normalized()*h*0.04
	var hbot = a1 + (a2-a1).normalized()*h*0.04
	draw_line(htop, hbot, Color(0.42,0.28,0.12), h*0.028)
	# Pommel
	draw_circle(a1 + (a2-a1).normalized()*h*0.02, h*0.04, Color(0.78,0.62,0.12))
	draw_circle(a1 + (a2-a1).normalized()*h*0.02, h*0.022, Color(0.9,0.78,0.3))
	# Sparkle
	draw_circle(a2, h*0.022, Color(1,0.95,0.6,0.9))
	draw_circle(a2, h*0.045, Color(1,0.92,0.4,0.35))

func _draw_village_scene(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.18,0.14,0.06,0.4))
	# Ground
	draw_rect(Rect2(0, h*0.72, w, h*0.28), Color(0.22,0.17,0.09))
	# Left building
	draw_rect(Rect2(w*0.04, h*0.28, w*0.22, h*0.44), Color(0.38,0.3,0.2))
	_poly([Vector2(w*0.02,h*0.28),Vector2(w*0.15,h*0.1),Vector2(w*0.28,h*0.28)], Color(0.28,0.2,0.12))
	draw_rect(Rect2(w*0.1,h*0.48,w*0.08,h*0.24), Color(0.18,0.1,0.05))
	# Right building
	draw_rect(Rect2(w*0.72, h*0.32, w*0.24, h*0.4), Color(0.4,0.32,0.22))
	_poly([Vector2(w*0.7,h*0.32),Vector2(w*0.84,h*0.14),Vector2(w*0.98,h*0.32)], Color(0.3,0.22,0.12))
	draw_rect(Rect2(w*0.78,h*0.52,w*0.09,h*0.2), Color(0.15,0.09,0.04))
	# Center stall / market
	draw_rect(Rect2(cx-w*0.12,h*0.4,w*0.24,h*0.32), Color(0.45,0.35,0.2))
	_poly([Vector2(cx-w*0.15,h*0.4),Vector2(cx,h*0.28),Vector2(cx+w*0.15,h*0.4)], Color(0.65,0.22,0.18))
	# Pennant strings
	for i in range(6):
		var px = w*0.2 + i*w*0.12
		draw_circle(Vector2(px, h*0.26), 4.5, [Color(0.85,0.2,0.2),Color(0.2,0.6,0.2),Color(0.2,0.2,0.85)][i%3])
	draw_line(Vector2(w*0.18,h*0.26), Vector2(w*0.82,h*0.26), Color(0.4,0.3,0.2), 1.5)
	# Warm torchlight glow
	draw_circle(Vector2(cx,cy+h*0.05), h*0.38, Color(0.9,0.6,0.2,0.08))
	# People silhouettes
	for px2 in [cx-h*0.2, cx, cx+h*0.18]:
		_oval(Vector2(px2, h*0.6), h*0.04, h*0.04, Color(0.18,0.12,0.08))
		draw_rect(Rect2(px2-h*0.03,h*0.64,h*0.06,h*0.1), Color(0.18,0.12,0.08))

func _draw_wedding_scene(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.1,0.06,0.18,0.4))
	# Soft glow background
	_oval(Vector2(cx,cy-h*0.04), h*0.42, h*0.4, Color(0.9,0.75,0.88,0.12))
	# Arch of flowers
	var ar = h*0.42
	for i in range(14):
		var a = PI + TAU*i/26
		var fx3 = cx + cos(a)*ar
		var fy3 = cy - h*0.04 + sin(a)*ar
		draw_circle(Vector2(fx3,fy3), h*0.03, [Color(0.95,0.75,0.82),Color(0.8,0.95,0.78),Color(0.95,0.92,0.7)][i%3])
		draw_circle(Vector2(fx3,fy3), h*0.018, Color(1,0.98,0.96))
	# Two figures facing each other
	var lx = cx - h*0.2; var rx = cx + h*0.2; var fy4 = cy - h*0.04
	# Left figure (in dress)
	_oval(Vector2(lx, fy4-h*0.26), h*0.12, h*0.13, Color(0.88,0.84,0.8))
	_poly([Vector2(lx-h*0.16,fy4-h*0.13),Vector2(lx+h*0.12,fy4-h*0.13),Vector2(lx+h*0.2,fy4+h*0.32),Vector2(lx-h*0.24,fy4+h*0.32)], Color(0.94,0.92,0.9))
	draw_line(Vector2(lx+h*0.12,fy4-h*0.1),Vector2(lx+h*0.2,fy4+h*0.05),Color(0.88,0.84,0.8),h*0.05)
	# Right figure (in dark coat)
	_oval(Vector2(rx, fy4-h*0.26), h*0.12, h*0.13, Color(0.82,0.76,0.7))
	_poly([Vector2(rx-h*0.12,fy4-h*0.13),Vector2(rx+h*0.12,fy4-h*0.13),Vector2(rx+h*0.12,fy4+h*0.32),Vector2(rx-h*0.12,fy4+h*0.32)], Color(0.22,0.18,0.28))
	draw_line(Vector2(rx-h*0.12,fy4-h*0.1),Vector2(rx-h*0.2,fy4+h*0.05),Color(0.82,0.76,0.7),h*0.05)
	# Hands meeting in center
	draw_circle(Vector2(cx,fy4+h*0.04), h*0.04, Color(0.88,0.82,0.76))
	# Hearts rising
	for hrt in [[-0.06,-0.12,0.7],[0,-0.2,0.9],[0.06,-0.14,0.6]]:
		var hx = cx + hrt[0]*h; var hy = cy + hrt[1]*h; var ha = hrt[2]
		draw_circle(Vector2(hx-h*0.018,hy-h*0.015), h*0.022, Color(0.92,0.35,0.55,ha))
		draw_circle(Vector2(hx+h*0.018,hy-h*0.015), h*0.022, Color(0.92,0.35,0.55,ha))
		_poly([Vector2(hx-h*0.038,hy-h*0.01),Vector2(hx,hy+h*0.042),Vector2(hx+h*0.038,hy-h*0.01)], Color(0.92,0.35,0.55,ha))
	# Candle lights at sides
	for cx3 in [cx-h*0.44, cx+h*0.44]:
		draw_line(Vector2(cx3,h*0.8),Vector2(cx3,h*0.45),Color(0.78,0.7,0.58),h*0.022)
		_poly([Vector2(cx3-h*0.03,h*0.45),Vector2(cx3,h*0.32),Vector2(cx3+h*0.03,h*0.45)],Color(0.92,0.72,0.22,0.88))
		draw_circle(Vector2(cx3,h*0.42),h*0.06,Color(0.95,0.78,0.3,0.2))

func _draw_camp_scene(w, h, cx, cy):
	draw_rect(Rect2(0,0,w,h), Color(0.1,0.08,0.04,0.45))
	draw_rect(Rect2(0, h*0.75, w, h*0.25), Color(0.12,0.09,0.05))
	# Fire glow on ground
	_oval(Vector2(cx, h*0.72), h*0.32, h*0.06, Color(0.88,0.45,0.06,0.22))
	# Log base
	_poly([Vector2(cx-h*0.22,h*0.74),Vector2(cx+h*0.22,h*0.74),Vector2(cx+h*0.18,h*0.78),Vector2(cx-h*0.18,h*0.78)], Color(0.28,0.17,0.08))
	_poly([Vector2(cx-h*0.12,h*0.71),Vector2(cx-h*0.2,h*0.79),Vector2(cx+h*0.2,h*0.79),Vector2(cx+h*0.12,h*0.71)], Color(0.22,0.13,0.06))
	# Flames
	for i in range(5):
		var fx = cx - h*0.12 + i*h*0.06
		var fh = h*(0.22+[0.06,0.12,0.16,0.1,0.05][i])
		_poly([Vector2(fx-h*0.03,h*0.74),Vector2(fx,h*0.74-fh),Vector2(fx+h*0.03,h*0.74)], Color(0.9,0.42+i*0.03,0.05,0.88))
	_poly([Vector2(cx-h*0.05,h*0.74),Vector2(cx,h*0.52),Vector2(cx+h*0.05,h*0.74)], Color(1,0.82,0.22,0.82))
	# Embers
	for em in [[-0.06,-0.08],[-0.14,-0.04],[0.04,-0.12],[0.12,-0.06]]:
		draw_circle(Vector2(cx+em[0]*h, h*0.74+em[1]*h), 2.5, Color(1,0.7,0.2,0.7))
	# Sitting figures around fire
	var positions = [cx - h*0.38, cx + h*0.35]
	for fx2 in positions:
		# Body (hunched sitting)
		_oval(Vector2(fx2, h*0.62), h*0.07, h*0.07, Color(0.55,0.48,0.4))
		_poly([Vector2(fx2-h*0.07,h*0.68),Vector2(fx2+h*0.07,h*0.68),Vector2(fx2+h*0.06,h*0.76),Vector2(fx2-h*0.06,h*0.76)], Color(0.35,0.28,0.22))
		# Legs on ground
		draw_line(Vector2(fx2-h*0.05,h*0.76),Vector2(fx2-h*0.12,h*0.8), Color(0.35,0.28,0.22), h*0.04)
		draw_line(Vector2(fx2+h*0.05,h*0.76),Vector2(fx2+h*0.12,h*0.8), Color(0.35,0.28,0.22), h*0.04)
	# Warm glow atmosphere
	_oval(Vector2(cx,h*0.62), h*0.5, h*0.36, Color(0.88,0.5,0.1,0.07))

func _draw_human_silhouette(w, h, cx, cy, col: Color):
	draw_circle(Vector2(cx,cy-h*0.28), h*0.13, col)
	_poly([Vector2(cx-h*0.12,cy-h*0.15),Vector2(cx+h*0.12,cy-h*0.15),Vector2(cx+h*0.1,cy+h*0.2),Vector2(cx-h*0.1,cy+h*0.2)], col)
	draw_line(Vector2(cx-h*0.12,cy-h*0.12), Vector2(cx-h*0.24,cy+h*0.08), col, h*0.06)
	draw_line(Vector2(cx+h*0.12,cy-h*0.12), Vector2(cx+h*0.24,cy+h*0.08), col, h*0.06)
	draw_line(Vector2(cx-h*0.06,cy+h*0.2), Vector2(cx-h*0.08,cy+h*0.42), col, h*0.065)
	draw_line(Vector2(cx+h*0.06,cy+h*0.2), Vector2(cx+h*0.08,cy+h*0.42), col, h*0.065)
