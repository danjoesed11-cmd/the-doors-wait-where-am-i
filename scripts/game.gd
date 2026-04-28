extends Control

const DoorPanel = preload("res://scripts/door_art.gd")

var round_label: Label
var hp_label: Label
var gold_label: Label
var partner_label: Label
var inv_bar: Control
var door_panels: Array = []
var fates: Array = []
var can_pick: bool = true

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fates = FateSystem.get_three_fates(PlayerStats.round_number)
	_build_ui()
	PlayerStats.stats_changed.connect(_update_hud)
	Inventory.inventory_changed.connect(_refresh_inv_bar)
	CompanionSystem.companions_changed.connect(_refresh_inv_bar)

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.030, 0.015, 0.062)
	add_child(bg)

	# Corridor perspective layers
	var corridor_levels = [
		[0.03, 0.97, 0.09, 0.55, Color(0.05, 0.025, 0.09)],
		[0.10, 0.90, 0.11, 0.53, Color(0.04, 0.020, 0.08)],
		[0.18, 0.82, 0.14, 0.51, Color(0.035,0.018, 0.072)],
		[0.27, 0.73, 0.18, 0.49, Color(0.028,0.014, 0.060)],
		[0.37, 0.63, 0.22, 0.47, Color(0.020,0.010, 0.045)],
	]
	for lvl in corridor_levels:
		var r := ColorRect.new()
		r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		r.anchor_left = lvl[0]; r.anchor_right  = lvl[1]
		r.anchor_top  = lvl[2]; r.anchor_bottom = lvl[3]
		r.color = lvl[4]
		add_child(r)

	# Torch glows
	_add_torch(0.06, 0.28)
	_add_torch(0.94, 0.28)

	var atmo := Label.new()
	atmo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmo.anchor_top = 0.26; atmo.anchor_bottom = 0.46
	atmo.text = "Choose wisely."
	atmo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	atmo.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	atmo.add_theme_font_size_override("font_size", 13)
	atmo.add_theme_color_override("font_color", Color(0.25, 0.16, 0.25))
	add_child(atmo)

	# HUD
	var hud := HBoxContainer.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hud.offset_bottom = 68.0
	add_child(hud)

	round_label = Label.new()
	round_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	round_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	round_label.add_theme_font_size_override("font_size", 16)
	round_label.add_theme_color_override("font_color", Color(0.8, 0.65, 0.2))
	hud.add_child(round_label)

	gold_label = Label.new()
	gold_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gold_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size", 16)
	gold_label.add_theme_color_override("font_color", Color(0.9, 0.76, 0.2))
	hud.add_child(gold_label)

	hp_label = Label.new()
	hp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	hp_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 16)
	hp_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	hud.add_child(hp_label)

	# Partner banner (below hud, shown when married)
	partner_label = Label.new()
	partner_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	partner_label.offset_top    = 68.0
	partner_label.offset_bottom = 90.0
	partner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	partner_label.add_theme_font_size_override("font_size", 11)
	partner_label.add_theme_color_override("font_color", Color(0.9, 0.55, 0.75))
	partner_label.visible = false
	add_child(partner_label)

	_update_hud()

	# Inventory bar (between corridor and doors)
	inv_bar = Control.new()
	inv_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inv_bar.anchor_top    = 0.56
	inv_bar.anchor_bottom = 0.72
	add_child(inv_bar)
	_populate_inv_bar()

	# Doors
	var doors_hbox := HBoxContainer.new()
	doors_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	doors_hbox.anchor_top    = 0.72
	doors_hbox.anchor_bottom = 0.99
	doors_hbox.offset_left   = 6
	doors_hbox.offset_right  = -6
	doors_hbox.add_theme_constant_override("separation", 6)
	doors_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(doors_hbox)

	var name_pool = DoorPanel.DOOR_NAMES.duplicate()
	name_pool.shuffle()

	for i in range(3):
		var dp := DoorPanel.new()
		dp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dp.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		dp.door_index = i
		doors_hbox.add_child(dp)
		dp.setup(i, name_pool[i], _hint_for_fate(fates[i]))
		dp.door_pressed.connect(_on_door_chosen.bind(i))
		door_panels.append(dp)

func _add_torch(ax: float, ay: float) -> void:
	var t := ColorRect.new()
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	t.anchor_left = ax - 0.03; t.anchor_right  = ax + 0.03
	t.anchor_top  = ay - 0.04; t.anchor_bottom = ay + 0.04
	t.color = Color(0.9, 0.55, 0.1, 0.18)
	add_child(t)

func _populate_inv_bar() -> void:
	for child in inv_bar.get_children():
		child.queue_free()

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6; vbox.offset_right = -6
	vbox.offset_top  = 4; vbox.offset_bottom = -4
	vbox.add_theme_constant_override("separation", 4)
	inv_bar.add_child(vbox)

	# Row 1 — weapons
	var weapons_row := HBoxContainer.new()
	weapons_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	weapons_row.add_theme_constant_override("separation", 4)
	vbox.add_child(weapons_row)

	for i in range(3):
		weapons_row.add_child(_weapon_slot(i))

	# Row 2 — heal + companions
	var bottom_row := HBoxContainer.new()
	bottom_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_row.add_theme_constant_override("separation", 4)
	vbox.add_child(bottom_row)

	bottom_row.add_child(_heal_slot())

	var comp_spacer := Control.new()
	comp_spacer.custom_minimum_size = Vector2(4, 0)
	bottom_row.add_child(comp_spacer)

	for i in range(2):
		bottom_row.add_child(_companion_slot(i))

func _weapon_slot(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_border_width_all(2)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	if index < Inventory.weapons.size():
		var w  = Inventory.weapons[index]
		var rc = Inventory.rarity_color(w.get("rarity", 0))
		style.bg_color     = Color(rc.r * 0.15, rc.g * 0.15, rc.b * 0.15, 0.9)
		style.border_color = rc

		var r_lbl := Label.new()
		r_lbl.text = Inventory.rarity_name(w.get("rarity", 0)).to_upper()
		r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r_lbl.add_theme_font_size_override("font_size", 8)
		r_lbl.add_theme_color_override("font_color", rc)
		vbox.add_child(r_lbl)

		var n_lbl := Label.new()
		n_lbl.text = w.get("name", "?")
		n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		n_lbl.add_theme_font_size_override("font_size", 10)
		n_lbl.add_theme_color_override("font_color", Color(0.88, 0.82, 0.72))
		vbox.add_child(n_lbl)

		var d_lbl := Label.new()
		d_lbl.text = "+%d DMG" % w.get("damage", 0)
		d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		d_lbl.add_theme_font_size_override("font_size", 9)
		d_lbl.add_theme_color_override("font_color", Color(0.6, 0.5, 0.35))
		vbox.add_child(d_lbl)
	else:
		style.bg_color     = Color(0.05, 0.03, 0.08, 0.6)
		style.border_color = Color(0.2, 0.15, 0.2)
		var e := Label.new()
		e.text = "WEAPON\nSLOT"
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.add_theme_font_size_override("font_size", 9)
		e.add_theme_color_override("font_color", Color(0.22, 0.18, 0.22))
		vbox.add_child(e)

	panel.add_theme_stylebox_override("panel", style)
	return panel

func _heal_slot() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(90, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_border_width_all(2)
	style.bg_color     = Color(0.08, 0.18, 0.08, 0.85)
	style.border_color = Color(0.2, 0.65, 0.3)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	var count_lbl := Label.new()
	count_lbl.text = "POTIONS  x%d" % Inventory.heal_count
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lbl.add_theme_font_size_override("font_size", 10)
	count_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	vbox.add_child(count_lbl)

	if Inventory.heal_count > 0 and PlayerStats.hp < PlayerStats.max_hp:
		var use_btn := Button.new()
		use_btn.text = "▲ USE ▲"
		use_btn.custom_minimum_size = Vector2(0, 22)
		use_btn.add_theme_font_size_override("font_size", 12)
		use_btn.add_theme_color_override("font_color", Color(0.3, 0.95, 0.45))
		var use_sty := StyleBoxFlat.new()
		use_sty.bg_color     = Color(0.05, 0.22, 0.08)
		use_sty.border_color = Color(0.25, 0.75, 0.32)
		use_sty.set_border_width_all(1)
		use_sty.set_corner_radius_all(3)
		use_btn.add_theme_stylebox_override("normal", use_sty)
		use_btn.pressed.connect(func(): Inventory.use_heal())
		vbox.add_child(use_btn)
	elif Inventory.heal_count > 0:
		var full_lbl := Label.new()
		full_lbl.text = "HP FULL"
		full_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		full_lbl.add_theme_font_size_override("font_size", 8)
		full_lbl.add_theme_color_override("font_color", Color(0.3, 0.55, 0.32))
		vbox.add_child(full_lbl)
	else:
		var dim := Label.new()
		dim.text = "heal +40"
		dim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dim.add_theme_font_size_override("font_size", 8)
		dim.add_theme_color_override("font_color", Color(0.22, 0.32, 0.22))
		vbox.add_child(dim)

	return panel

func _companion_slot(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_border_width_all(2)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	if index < CompanionSystem.companions.size():
		var c  = CompanionSystem.companions[index]
		var tc = CompanionSystem.type_color(c.get("type", ""))
		style.bg_color     = Color(tc.r * 0.15, tc.g * 0.15, tc.b * 0.15, 0.9)
		style.border_color = tc

		var n_lbl := Label.new()
		n_lbl.text = c.get("name", "?")
		n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		n_lbl.add_theme_font_size_override("font_size", 10)
		n_lbl.add_theme_color_override("font_color", Color(0.88, 0.82, 0.72))
		vbox.add_child(n_lbl)

		var rel = c.get("relationship", 50)
		var rel_lbl := Label.new()
		rel_lbl.text = _rel_label(rel)
		rel_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rel_lbl.add_theme_font_size_override("font_size", 8)
		rel_lbl.add_theme_color_override("font_color", tc)
		vbox.add_child(rel_lbl)
	else:
		style.bg_color     = Color(0.05, 0.03, 0.08, 0.6)
		style.border_color = Color(0.2, 0.15, 0.2)
		var e := Label.new()
		e.text = "ALLY\nSLOT"
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.add_theme_font_size_override("font_size", 9)
		e.add_theme_color_override("font_color", Color(0.22, 0.18, 0.22))
		vbox.add_child(e)

	panel.add_theme_stylebox_override("panel", style)
	return panel

const _HINTS = [
	["The air grows cold.", "Something watches from within.", "Complete silence.", "The door feels heavier.", "A smell you cannot name."],
	["Impossible warmth.", "A sound like singing.", "The door practically vibrates.", "Light. Actual light."],
	["Something shifts in the dark.", "You hear breathing.", "A low sound. Maybe a growl.", "The handle is warm."],
	["The floor creaks wrong.", "A faint hiss from within.", "The air tastes of metal.", "Something drips."],
	["Warm light seeps through.", "The door feels lighter.", "A gentle hum.", "It smells of rain."],
	["Candlelight flickers beyond.", "You hear pages turning.", "A voice. Barely.", "Someone is already inside."],
	["A dull gleam at the keyhole.", "Metal. Old, but kept.", "The weight of steel.", "Something was left behind."],
	["A shadow moves — human-shaped.", "Controlled breathing.", "Not alone in there.", "Knocking. From inside."],
	["Something glows faintly.", "A scent of herbs.", "Faint warmth.", "Glass. Liquid. Something."],
	["Torchlight and voices.", "You smell bread and ale.", "The sound of commerce.", "Distant laughter beyond."],
	["A familiar warmth.", "Someone watches you kindly.", "Your name, spoken gently.", "You are not alone here."],
]

func _hint_for_fate(fate) -> String:
	var pool = _HINTS[clamp(fate.type, 0, _HINTS.size()-1)]
	return pool[abs(fate.id.hash()) % pool.size()]

func _rel_label(rel: int) -> String:
	if rel >= 85: return "DEVOTED"
	if rel >= 65: return "TRUSTED"
	if rel >= 45: return "ALLIED"
	if rel >= 25: return "WARY"
	return "HOSTILE"

func _update_hud() -> void:
	if round_label:  round_label.text  = "  ROUND  %d" % PlayerStats.round_number
	if gold_label:   gold_label.text   = "%dg" % PlayerStats.gold
	if hp_label:     hp_label.text     = "HP  %d/%d  " % [PlayerStats.hp, PlayerStats.max_hp]
	if partner_label:
		if PlayerStats.is_married():
			partner_label.text    = "♥  %s is with you  ♥" % PlayerStats.partner.get("name", "")
			partner_label.visible = true
		else:
			partner_label.visible = false

func _refresh_inv_bar() -> void:
	if not is_inside_tree() or not inv_bar or not is_instance_valid(inv_bar):
		return
	_populate_inv_bar()

func _on_door_chosen(index: int) -> void:
	if not can_pick:
		return
	can_pick = false
	for dp in door_panels:
		dp.disable()
	GameManager.open_door(fates[index])
