extends Control

var hp_label: Label
var type_label: Label
var title_label: Label
var desc_label: Label
var flavor_label: Label
var enemy_label: Label
var fight_btn: Button
var continue_btn: Button
var action_area: VBoxContainer

var fate = null
var enemy_hp: int = 0
var enemy_power: int = 0
var is_win_fight: bool = false

const TYPE_NAMES  = ["DEATH","VICTORY","COMBAT","TRAP","BOON","LORE","WEAPON","COMPANION","ITEM"]
const TYPE_COLORS = [
	Color(0.9,0.15,0.15), Color(1.0,0.85,0.2), Color(0.9,0.5,0.1),
	Color(0.7,0.2,0.7),   Color(0.2,0.8,0.4),  Color(0.4,0.7,0.9),
	Color(0.95,0.6,0.1),  Color(0.3,0.9,0.6),  Color(0.2,0.85,0.5),
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fate = GameManager.current_fate
	_build_ui()
	await get_tree().create_timer(0.3).timeout
	_apply_fate()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.025, 0.01, 0.055)
	add_child(bg)

	# HUD
	var hud := HBoxContainer.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	hud.offset_bottom = 60.0
	add_child(hud)

	hp_label = Label.new()
	hp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	hp_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 17)
	hp_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	_refresh_hp()
	hud.add_child(hp_label)

	# Scroll area
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top    = 64.0
	scroll.offset_bottom = -230.0
	add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)

	type_label = Label.new()
	type_label.text = "[ %s ]" % TYPE_NAMES[fate.type]
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 15)
	type_label.add_theme_color_override("font_color", TYPE_COLORS[fate.type])
	type_label.custom_minimum_size = Vector2(0, 36)
	content.add_child(type_label)

	title_label = Label.new()
	title_label.text = fate.title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.7))
	title_label.custom_minimum_size = Vector2(0, 70)
	content.add_child(title_label)

	var art := FateArt.new()
	art.custom_minimum_size = Vector2(0, 180)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.setup(fate.id, fate.type, fate.effect.get("enemy_name", ""))
	content.add_child(art)

	var div := Label.new()
	div.text = "— — — — — — — — — — —"
	div.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	div.add_theme_font_size_override("font_size", 12)
	div.add_theme_color_override("font_color", Color(0.3, 0.2, 0.3))
	content.add_child(div)

	desc_label = Label.new()
	desc_label.text = fate.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 19)
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.78, 0.7))
	desc_label.custom_minimum_size = Vector2(0, 70)
	content.add_child(desc_label)

	flavor_label = Label.new()
	flavor_label.text = "\"%s\"" % fate.flavor
	flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor_label.add_theme_font_size_override("font_size", 15)
	flavor_label.add_theme_color_override("font_color", Color(0.55, 0.48, 0.55))
	flavor_label.custom_minimum_size = Vector2(0, 60)
	content.add_child(flavor_label)

	# Action area
	action_area = VBoxContainer.new()
	action_area.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	action_area.offset_top    = -225.0
	action_area.offset_left   = 12.0
	action_area.offset_right  = -12.0
	action_area.offset_bottom = -8.0
	action_area.add_theme_constant_override("separation", 10)
	add_child(action_area)

	enemy_label = Label.new()
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_label.add_theme_font_size_override("font_size", 20)
	enemy_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.2))
	enemy_label.visible = false
	action_area.add_child(enemy_label)

	fight_btn = Button.new()
	fight_btn.text = "FIGHT"
	fight_btn.custom_minimum_size = Vector2(0, 62)
	fight_btn.add_theme_font_size_override("font_size", 22)
	fight_btn.add_theme_color_override("font_color", Color(0.95, 0.4, 0.2))
	fight_btn.visible = false
	fight_btn.pressed.connect(_on_fight)
	action_area.add_child(fight_btn)

	continue_btn = Button.new()
	continue_btn.text = "CONTINUE →"
	continue_btn.custom_minimum_size = Vector2(0, 62)
	continue_btn.add_theme_font_size_override("font_size", 20)
	continue_btn.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	continue_btn.visible = false
	continue_btn.pressed.connect(_on_continue)
	action_area.add_child(continue_btn)

func _refresh_hp() -> void:
	if hp_label:
		hp_label.text = "HP  %d / %d  " % [PlayerStats.hp, PlayerStats.max_hp]

func _apply_fate() -> void:
	match fate.type:
		FateSystem.FateType.DEATH:
			await get_tree().create_timer(2.5).timeout
			GameManager.complete_fate({"outcome": "death", "cause": fate.id})
		FateSystem.FateType.WIN:
			if fate.effect.get("requires_combat", false):
				_start_combat(fate.effect, true)
			else:
				await get_tree().create_timer(2.5).timeout
				GameManager.complete_fate({"outcome": "win", "ending": fate.id})
		FateSystem.FateType.COMBAT:
			_start_combat(fate.effect, false)
		FateSystem.FateType.TRAP:
			_handle_trap()
		FateSystem.FateType.BOON:
			_handle_boon()
		FateSystem.FateType.STORY:
			if fate.effect.get("luck", 0) > 0:
				PlayerStats.add_luck(fate.effect["luck"])
			continue_btn.visible = true
		FateSystem.FateType.WEAPON:
			_handle_weapon()
		FateSystem.FateType.COMPANION:
			_handle_companion()
		FateSystem.FateType.ITEM:
			_handle_item()

func _handle_trap() -> void:
	var dmg  = fate.effect.get("damage", 0)
	var luck = fate.effect.get("luck", 0)
	if dmg > 0:
		var reduction = CompanionSystem.get_trap_reduction()
		var actual    = int(dmg * (1.0 - reduction))
		if reduction > 0:
			desc_label.text += "\n\nKira reduces the damage. (%d → %d)" % [dmg, actual]
		PlayerStats.take_damage(actual)
		_refresh_hp()
	if luck != 0:
		PlayerStats.add_luck(luck)
	await get_tree().create_timer(1.0).timeout
	if not PlayerStats.is_alive():
		_check_revive_or_die("trap")
	else:
		continue_btn.visible = true

func _handle_boon() -> void:
	var heal = fate.effect.get("heal", 0)
	var luck = fate.effect.get("luck", 0)
	if heal > 0:
		PlayerStats.heal(heal)
		_refresh_hp()
	if luck > 0:
		PlayerStats.add_luck(luck)
	continue_btn.visible = true

func _handle_weapon() -> void:
	var min_r = fate.effect.get("min_rarity", 0)
	var max_r = fate.effect.get("max_rarity", 2)
	var weapon = Inventory.get_random_weapon(min_r, max_r)

	var rc = Inventory.rarity_color(weapon.get("rarity", 0))
	type_label.text = "[ %s WEAPON ]" % Inventory.rarity_name(weapon.get("rarity", 0)).to_upper()
	type_label.add_theme_color_override("font_color", rc)
	title_label.text = weapon.get("name", "Unknown Weapon")
	title_label.add_theme_color_override("font_color", rc)
	desc_label.text  = weapon.get("desc", "")
	flavor_label.text = "Damage bonus: +%d" % weapon.get("damage", 0)

	if Inventory.add_weapon(weapon):
		desc_label.text += "\n\nAdded to your arsenal."
		continue_btn.visible = true
	else:
		_show_weapon_swap(weapon)

func _show_weapon_swap(new_w: Dictionary) -> void:
	var lbl := Label.new()
	lbl.text = "Your arsenal is full. Replace a weapon or leave it."
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.75, 0.65, 0.5))
	action_area.add_child(lbl)

	for i in range(Inventory.weapons.size()):
		var w  = Inventory.weapons[i]
		var rc = Inventory.rarity_color(w.get("rarity", 0))
		var slot_btn := Button.new()
		slot_btn.text = "DROP: %s  [%s  +%d DMG]" % [
			w.get("name", "?"),
			Inventory.rarity_name(w.get("rarity", 0)),
			w.get("damage", 0)
		]
		slot_btn.custom_minimum_size = Vector2(0, 48)
		slot_btn.add_theme_font_size_override("font_size", 13)
		slot_btn.add_theme_color_override("font_color", rc)
		var captured_i = i
		slot_btn.pressed.connect(func():
			Inventory.replace_weapon(captured_i, new_w)
			_on_continue()
		)
		action_area.add_child(slot_btn)

	var leave_btn := Button.new()
	leave_btn.text = "LEAVE IT BEHIND"
	leave_btn.custom_minimum_size = Vector2(0, 44)
	leave_btn.add_theme_font_size_override("font_size", 14)
	leave_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	leave_btn.pressed.connect(_on_continue)
	action_area.add_child(leave_btn)

func _handle_companion() -> void:
	var companion = CompanionSystem.get_random_companion()
	if companion.is_empty():
		desc_label.text = "A stranger sits here — but your party is already full, and your heart with it."
		continue_btn.visible = true
		return

	var tc = CompanionSystem.type_color(companion.get("type", ""))
	type_label.text = "[ COMPANION — %s ]" % companion.get("type", "").to_upper()
	type_label.add_theme_color_override("font_color", tc)
	title_label.text = companion.get("name", "Stranger")
	title_label.add_theme_color_override("font_color", tc)
	desc_label.text  = companion.get("desc", "")
	flavor_label.text = "Passive: %s" % companion.get("passive", "")

	if CompanionSystem.companions.size() < CompanionSystem.MAX_COMPANIONS:
		var accept_btn := Button.new()
		accept_btn.text = "ACCEPT THEIR COMPANY"
		accept_btn.custom_minimum_size = Vector2(0, 58)
		accept_btn.add_theme_font_size_override("font_size", 18)
		accept_btn.add_theme_color_override("font_color", tc)
		accept_btn.pressed.connect(func():
			CompanionSystem.add_companion(companion)
			_on_continue()
		)
		action_area.add_child(accept_btn)
	else:
		var swap_lbl := Label.new()
		swap_lbl.text = "Your party is full. Replace a companion?"
		swap_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		swap_lbl.add_theme_font_size_override("font_size", 13)
		swap_lbl.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))
		action_area.add_child(swap_lbl)

		for i in range(CompanionSystem.companions.size()):
			var c   = CompanionSystem.companions[i]
			var ctc = CompanionSystem.type_color(c.get("type", ""))
			var rb  := Button.new()
			rb.text = "REPLACE: %s  (%s)" % [c.get("name", "?"), c.get("type", "")]
			rb.custom_minimum_size = Vector2(0, 46)
			rb.add_theme_font_size_override("font_size", 13)
			rb.add_theme_color_override("font_color", ctc)
			var captured_i = i
			rb.pressed.connect(func():
				CompanionSystem.replace_companion(captured_i, companion)
				_on_continue()
			)
			action_area.add_child(rb)

	var decline_btn := Button.new()
	decline_btn.text = "PART WAYS"
	decline_btn.custom_minimum_size = Vector2(0, 44)
	decline_btn.add_theme_font_size_override("font_size", 14)
	decline_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	decline_btn.pressed.connect(_on_continue)
	action_area.add_child(decline_btn)

func _handle_item() -> void:
	var count = fate.effect.get("count", 1)
	Inventory.add_heal(count)
	desc_label.text += "\n\nFound %d healing potion%s." % [count, "s" if count > 1 else ""]
	continue_btn.visible = true

func _start_combat(effect: Dictionary, win_fight: bool) -> void:
	is_win_fight = win_fight
	enemy_hp     = effect.get("enemy_hp", 30)
	enemy_power  = effect.get("enemy_power", 10)
	enemy_label.text    = "%s\nHP: %d" % [effect.get("enemy_name", "Beast"), enemy_hp]
	enemy_label.visible = true
	fight_btn.visible   = true
	_refresh_potion_btn()

func _refresh_potion_btn() -> void:
	var existing = action_area.get_node_or_null("PotionBtn")
	if existing:
		existing.queue_free()
	if Inventory.heal_count <= 0:
		return
	var btn := Button.new()
	btn.name = "PotionBtn"
	btn.text = "USE POTION  (x%d)  [ +40 HP ]" % Inventory.heal_count
	btn.custom_minimum_size = Vector2(0, 48)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.45))
	var sty := StyleBoxFlat.new()
	sty.bg_color     = Color(0.04, 0.16, 0.07)
	sty.border_color = Color(0.22, 0.65, 0.28)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", sty)
	btn.pressed.connect(func():
		if Inventory.use_heal():
			_refresh_hp()
			_refresh_potion_btn()
	)
	action_area.add_child(btn)
	action_area.move_child(btn, 0)

func _on_fight() -> void:
	var dodge = CompanionSystem.get_dodge_bonus()
	var p = randi() % 20 + 1 + PlayerStats.get_combat_power()
	var e = randi() % 20 + 1 + enemy_power - dodge

	if p >= e:
		var dmg = max(5, p - e + 6)
		enemy_hp -= dmg
		enemy_label.text = enemy_label.text.split("\n")[0] + "\nHP: %d" % max(0, enemy_hp)
		if enemy_hp <= 0:
			_combat_victory()
	else:
		var dmg = max(3, e - p + 4)
		PlayerStats.take_damage(dmg)
		_refresh_hp()
		if not PlayerStats.is_alive():
			fight_btn.disabled = true
			desc_label.text = "Your strength fails. The darkness takes you."
			await get_tree().create_timer(1.5).timeout
			_check_revive_or_die("combat")

func _combat_victory() -> void:
	fight_btn.visible   = false
	enemy_label.visible = false
	PlayerStats.combat_wins += 1
	var luck = fate.effect.get("reward_luck", 0)
	if luck > 0: PlayerStats.add_luck(luck)
	if is_win_fight:
		desc_label.text = "You have defeated Satan himself. Hell bows at your feet."
		await get_tree().create_timer(2.5).timeout
		GameManager.complete_fate({"outcome": "win", "ending": fate.id})
	else:
		desc_label.text = "You stand victorious. The creature falls."
		continue_btn.visible = true

func _check_revive_or_die(cause: String) -> void:
	if CompanionSystem.check_revive():
		CompanionSystem.use_revive()
		desc_label.text = "Lyria pulls you back from the brink. You survive — barely."
		_refresh_hp()
		await get_tree().create_timer(1.5).timeout
		continue_btn.visible = true
	else:
		GameManager.complete_fate({"outcome": "death", "cause": cause})

func _on_continue() -> void:
	GameManager.complete_fate({"outcome": "continue"})
