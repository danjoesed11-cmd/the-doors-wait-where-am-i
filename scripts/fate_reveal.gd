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
var _content: VBoxContainer
var _scroll: ScrollContainer

var fate = null
var enemy_hp: int = 0
var enemy_power: int = 0
var is_win_fight: bool = false
var _is_first_strike: bool = false
var _casino_result: String = ""
var _casino_result_win: bool = false

const TYPE_NAMES = ["DEATH","VICTORY","COMBAT","TRAP","BOON","LORE","WEAPON","COMPANION","ITEM","VILLAGE","MARRIAGE","COMPANION CAMP"]
const TYPE_COLORS = [
	Color(0.9,0.15,0.15), Color(1.0,0.85,0.2),  Color(0.9,0.5,0.1),
	Color(0.7,0.2,0.7),   Color(0.2,0.8,0.4),   Color(0.4,0.7,0.9),
	Color(0.95,0.6,0.1),  Color(0.3,0.9,0.6),   Color(0.2,0.85,0.5),
	Color(0.82,0.68,0.3), Color(0.95,0.55,0.75), Color(0.88,0.65,0.3),
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

	_scroll = ScrollContainer.new()
	var scroll = _scroll
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top    = 64.0
	scroll.offset_bottom = -240.0
	add_child(scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 14)
	scroll.add_child(_content)
	var content = _content

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
	desc_label.custom_minimum_size = Vector2(0, 60)
	content.add_child(desc_label)

	flavor_label = Label.new()
	flavor_label.text = "\"%s\"" % fate.flavor
	flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor_label.add_theme_font_size_override("font_size", 15)
	flavor_label.add_theme_color_override("font_color", Color(0.55, 0.48, 0.55))
	flavor_label.custom_minimum_size = Vector2(0, 55)
	content.add_child(flavor_label)

	action_area = VBoxContainer.new()
	action_area.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	action_area.offset_top    = -235.0
	action_area.offset_left   = 12.0
	action_area.offset_right  = -12.0
	action_area.offset_bottom = -8.0
	action_area.add_theme_constant_override("separation", 8)
	add_child(action_area)

	enemy_label = Label.new()
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_label.add_theme_font_size_override("font_size", 20)
	enemy_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.2))
	enemy_label.visible = false
	action_area.add_child(enemy_label)

	fight_btn = Button.new()
	fight_btn.text = "FIGHT"
	fight_btn.custom_minimum_size = Vector2(0, 58)
	fight_btn.add_theme_font_size_override("font_size", 22)
	fight_btn.add_theme_color_override("font_color", Color(0.95, 0.4, 0.2))
	fight_btn.visible = false
	fight_btn.pressed.connect(_on_fight)
	action_area.add_child(fight_btn)

	continue_btn = Button.new()
	continue_btn.text = "CONTINUE →"
	continue_btn.custom_minimum_size = Vector2(0, 58)
	continue_btn.add_theme_font_size_override("font_size", 20)
	continue_btn.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	continue_btn.visible = false
	continue_btn.pressed.connect(_on_continue)
	action_area.add_child(continue_btn)

func _refresh_hp() -> void:
	if hp_label:
		hp_label.text = "  HP  %d/%d   Gold %dg  " % [PlayerStats.hp, PlayerStats.max_hp, PlayerStats.gold]

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
		FateSystem.FateType.VILLAGE:
			_handle_village()
		FateSystem.FateType.MARRIAGE:
			_handle_marriage()
		FateSystem.FateType.COMPANION_INTERACT:
			_handle_companion_interact()

# ── TRAP ──────────────────────────────────────────────────────────────
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

# ── BOON ──────────────────────────────────────────────────────────────
func _handle_boon() -> void:
	var heal       = fate.effect.get("heal", 0)
	var luck       = fate.effect.get("luck", 0)
	var max_hp_add = fate.effect.get("max_hp", 0)
	var gold_add   = fate.effect.get("gold", 0)
	if heal > 0:       PlayerStats.heal(heal);             _refresh_hp()
	if luck > 0:       PlayerStats.add_luck(luck)
	if max_hp_add > 0: PlayerStats.increase_max_hp(max_hp_add); _refresh_hp()
	if gold_add > 0:   PlayerStats.earn_gold(gold_add);    _refresh_hp()
	continue_btn.visible = true

# ── WEAPON ────────────────────────────────────────────────────────────
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
		slot_btn.text = "DROP: %s  [%s  +%d DMG]" % [w.get("name","?"), Inventory.rarity_name(w.get("rarity",0)), w.get("damage",0)]
		slot_btn.custom_minimum_size = Vector2(0, 46)
		slot_btn.add_theme_font_size_override("font_size", 13)
		slot_btn.add_theme_color_override("font_color", rc)
		var ci = i
		slot_btn.pressed.connect(func(): Inventory.replace_weapon(ci, new_w); _on_continue())
		action_area.add_child(slot_btn)
	var leave_btn := Button.new()
	leave_btn.text = "LEAVE IT BEHIND"
	leave_btn.custom_minimum_size = Vector2(0, 42)
	leave_btn.add_theme_font_size_override("font_size", 14)
	leave_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	leave_btn.pressed.connect(_on_continue)
	action_area.add_child(leave_btn)

# ── COMPANION ─────────────────────────────────────────────────────────
func _handle_companion() -> void:
	var companion = CompanionSystem.get_random_companion()
	if companion.is_empty():
		desc_label.text = "A stranger sits here — but your party is already full."
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
		accept_btn.custom_minimum_size = Vector2(0, 56)
		accept_btn.add_theme_font_size_override("font_size", 18)
		accept_btn.add_theme_color_override("font_color", tc)
		accept_btn.pressed.connect(func(): CompanionSystem.add_companion(companion); _on_continue())
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
			rb.text = "REPLACE: %s  (%s)" % [c.get("name","?"), c.get("type","")]
			rb.custom_minimum_size = Vector2(0, 44)
			rb.add_theme_font_size_override("font_size", 13)
			rb.add_theme_color_override("font_color", ctc)
			var ci = i
			rb.pressed.connect(func(): CompanionSystem.replace_companion(ci, companion); _on_continue())
			action_area.add_child(rb)
	var decline_btn := Button.new()
	decline_btn.text = "PART WAYS"
	decline_btn.custom_minimum_size = Vector2(0, 42)
	decline_btn.add_theme_font_size_override("font_size", 14)
	decline_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	decline_btn.pressed.connect(_on_continue)
	action_area.add_child(decline_btn)

# ── ITEM ──────────────────────────────────────────────────────────────
func _handle_item() -> void:
	var count = fate.effect.get("count", 1)
	Inventory.add_heal(count)
	desc_label.text += "\n\nFound %d healing potion%s." % [count, "s" if count > 1 else ""]
	continue_btn.visible = true

# ── VILLAGE / SHOP ────────────────────────────────────────────────────
func _handle_village() -> void:
	var vtype = fate.effect.get("village_type", "market")

	# Push scroll area almost to the bottom so shop items have maximum room
	_scroll.offset_bottom = -75.0
	action_area.offset_top = -70.0

	# Hide the large art block (saves ~180px) and shrink label min sizes
	for c in _content.get_children():
		if c is FateArt:
			c.visible = false
			c.custom_minimum_size = Vector2(0, 0)
	desc_label.custom_minimum_size   = Vector2(0, 30)
	flavor_label.custom_minimum_size = Vector2(0, 30)

	var shop_box := VBoxContainer.new()
	shop_box.add_theme_constant_override("separation", 6)
	_content.add_child(shop_box)
	continue_btn.visible = true
	if vtype == "casino":
		_casino_result = ""
		_casino_result_win = false
		_rebuild_casino(shop_box)
	else:
		_fill_shop(shop_box, vtype)

func _fill_shop(box: VBoxContainer, vtype: String) -> void:
	for c in box.get_children():
		c.queue_free()
	await get_tree().process_frame

	var gold_lbl := Label.new()
	gold_lbl.text = "YOUR GOLD:  %dg" % PlayerStats.gold
	gold_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_lbl.add_theme_font_size_override("font_size", 16)
	gold_lbl.add_theme_color_override("font_color", Color(0.92, 0.78, 0.2))
	box.add_child(gold_lbl)

	for item in _shop_items(vtype):
		var can_afford = PlayerStats.gold >= item["cost"]
		var btn := Button.new()
		btn.text = "%s   —   %dg" % [item["name"], item["cost"]]
		btn.custom_minimum_size = Vector2(0, 42)
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(0.88, 0.78, 0.5) if can_afford else Color(0.45, 0.4, 0.35))
		btn.disabled = not can_afford
		var item_ref = item
		var box_ref  = box
		btn.pressed.connect(func():
			if PlayerStats.spend_gold(item_ref["cost"]):
				item_ref["action"].call()
				_refresh_hp()
				_fill_shop(box_ref, vtype)
		)
		box.add_child(btn)

func _shop_items(vtype: String) -> Array:
	match vtype:
		"inn":
			return [
				{"name": "Full Meal & Rest  (full HP)", "cost": 45,
				 "action": func(): PlayerStats.heal(PlayerStats.max_hp)},
				{"name": "Healing Tonic  (+1 potion)", "cost": 22,
				 "action": func(): Inventory.add_heal(1)},
				{"name": "Warm Bed  (+20 max HP)", "cost": 95,
				 "action": func(): PlayerStats.increase_max_hp(20)},
			]
		"blacksmith":
			var min_r = clamp(int(PlayerStats.round_number / 5) - 1, 0, 5)
			var max_r = clamp(int(PlayerStats.round_number / 5) + 1, 1, 6)
			var bw = Inventory.get_random_weapon(min_r, max_r)
			var bcost = 30 + bw.get("rarity", 0) * 22
			return [
				{"name": "%s  (%s  +%d)" % [bw.get("name","?"), Inventory.rarity_name(bw.get("rarity",0)), bw.get("damage",0)],
				 "cost": bcost,
				 "action": func():
				 	if not Inventory.add_weapon(bw): Inventory.replace_weapon(0, bw)},
				{"name": "Polish Top Weapon  (+8 DMG)", "cost": 40,
				 "action": func(): _upgrade_top_weapon(8)},
				{"name": "Healing Potion  (+1)", "cost": 28,
				 "action": func(): Inventory.add_heal(1)},
			]
		"alchemist":
			return [
				{"name": "Healing Potion  (+1)", "cost": 15,
				 "action": func(): Inventory.add_heal(1)},
				{"name": "Potion Bundle  (+3)", "cost": 38,
				 "action": func(): Inventory.add_heal(3)},
				{"name": "Elixir of Fortune  (+3 luck)", "cost": 55,
				 "action": func(): PlayerStats.add_luck(3)},
				{"name": "Strength Draught  (+20 max HP)", "cost": 72,
				 "action": func(): PlayerStats.increase_max_hp(20)},
			]
		"sage":
			return [
				{"name": "Tome of Luck  (+4 luck)", "cost": 52,
				 "action": func(): PlayerStats.add_luck(4)},
				{"name": "Combat Treatise  (+2 combat power)", "cost": 42,
				 "action": func(): PlayerStats.combat_wins += 1},
				{"name": "Life Crystal  (+30 max HP)", "cost": 115,
				 "action": func(): PlayerStats.increase_max_hp(30)},
				{"name": "Healing Herb  (+1 potion)", "cost": 18,
				 "action": func(): Inventory.add_heal(1)},
			]
		_:  # market
			return [
				{"name": "Healing Potion  (+1)", "cost": 20,
				 "action": func(): Inventory.add_heal(1)},
				{"name": "Potion Crate  (+3)", "cost": 50,
				 "action": func(): Inventory.add_heal(3)},
				{"name": "Lucky Charm  (+2 luck)", "cost": 35,
				 "action": func(): PlayerStats.add_luck(2)},
				{"name": "Full Restoration  (full HP)", "cost": 80,
				 "action": func(): PlayerStats.heal(PlayerStats.max_hp)},
				{"name": "Adventurer Pack  (+50 HP, +2 potions)", "cost": 68,
				 "action": func(): PlayerStats.heal(50); Inventory.add_heal(2)},
			]

# ── CASINO ────────────────────────────────────────────────────────────
func _rebuild_casino(box: VBoxContainer) -> void:
	for c in box.get_children():
		if c is Button: c.disabled = true
		c.queue_free()
	await get_tree().process_frame

	var gold_lbl := Label.new()
	gold_lbl.text = "YOUR GOLD:  %dg" % PlayerStats.gold
	gold_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_lbl.add_theme_font_size_override("font_size", 16)
	gold_lbl.add_theme_color_override("font_color", Color(0.92, 0.78, 0.2))
	box.add_child(gold_lbl)

	if _casino_result != "":
		var r_lbl := Label.new()
		r_lbl.text = _casino_result
		r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		r_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_lbl.add_theme_font_size_override("font_size", 14)
		r_lbl.add_theme_color_override("font_color",
			Color(0.3, 0.95, 0.45) if _casino_result_win else Color(0.95, 0.32, 0.32))
		box.add_child(r_lbl)

	var games = [
		{"name": "Coin Flip  —  15g",      "odds": "50/50  ·  win 15g or lose 15g",                    "cost": 15,  "fn": func(): _casino_flip(15, box)},
		{"name": "High Stakes  —  40g",    "odds": "50/50  ·  win 40g or lose 40g",                    "cost": 40,  "fn": func(): _casino_flip(40, box)},
		{"name": "Lucky Roll  —  20g",     "odds": "d20  ·  1-9: lose  ·  15-19: +40g  ·  20: +80g!", "cost": 20,  "fn": func(): _casino_lucky_roll(box)},
		{"name": "Weapon Crate  —  30g",   "odds": "Draw a mystery weapon  (min Rare, scales with round)","cost": 30,"fn": func(): _casino_weapon(box)},
		{"name": "Potion Slots  —  12g",   "odds": "Spin  ·  40%: nothing  ·  35%: +2 pot  ·  25%: +5 pots!","cost": 12,"fn": func(): _casino_potions(box)},
		{"name": "Health Gamble  —  35g",  "odds": "40%: +30 max HP  ·  60%: lose gold",               "cost": 35,  "fn": func(): _casino_health(box)},
		{"name": "Devil's Wager  —  45g",  "odds": "50/50  ·  WIN: +45g +5 luck  ·  LOSE: -45g -2 luck","cost": 45, "fn": func(): _casino_devil(box)},
	]

	for g in games:
		var can = PlayerStats.gold >= g["cost"]
		var g_box := VBoxContainer.new()
		g_box.add_theme_constant_override("separation", 2)
		box.add_child(g_box)
		var btn := Button.new()
		btn.text = g["name"]
		btn.custom_minimum_size = Vector2(0, 42)
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color",
			Color(0.92, 0.72, 0.15) if can else Color(0.42, 0.38, 0.3))
		btn.disabled = not can
		btn.pressed.connect(g["fn"])
		g_box.add_child(btn)
		var odds_lbl := Label.new()
		odds_lbl.text = g["odds"]
		odds_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		odds_lbl.add_theme_font_size_override("font_size", 10)
		odds_lbl.add_theme_color_override("font_color", Color(0.55, 0.5, 0.4))
		g_box.add_child(odds_lbl)

func _casino_flip(bet: int, box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(bet): return
	if randf() < 0.5:
		PlayerStats.earn_gold(bet * 2)
		_casino_result = "HEADS! You win %dg!" % bet
		_casino_result_win = true
	else:
		_casino_result = "TAILS. You lose %dg." % bet
		_casino_result_win = false
	_refresh_hp(); _rebuild_casino(box)

func _casino_lucky_roll(box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(20): return
	var roll = randi() % 20 + 1
	if roll <= 9:
		_casino_result = "Rolled %d. Unlucky — lost 20g." % roll
		_casino_result_win = false
	elif roll <= 14:
		PlayerStats.earn_gold(20)
		_casino_result = "Rolled %d. Broke even — 20g back." % roll
		_casino_result_win = true
	elif roll <= 19:
		PlayerStats.earn_gold(40)
		_casino_result = "Rolled %d! You win 40g!" % roll
		_casino_result_win = true
	else:
		PlayerStats.earn_gold(80)
		_casino_result = "NATURAL 20!!! JACKPOT — 80g!!!"
		_casino_result_win = true
	_refresh_hp(); _rebuild_casino(box)

func _casino_weapon(box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(30): return
	var min_r = clamp(int(PlayerStats.round_number / 4), 1, 5)
	var max_r = clamp(min_r + 2, min_r, 6)
	var w = Inventory.get_random_weapon(min_r, max_r)
	var rname = Inventory.rarity_name(w.get("rarity", 0))
	if Inventory.add_weapon(w):
		_casino_result = "Drew: %s  [%s  +%d DMG]!" % [w.get("name","?"), rname, w.get("damage",0)]
	else:
		var weakest = 0
		for i in range(1, Inventory.weapons.size()):
			if Inventory.weapons[i].get("damage",0) < Inventory.weapons[weakest].get("damage",0):
				weakest = i
		var old = Inventory.weapons[weakest].get("name","?")
		Inventory.replace_weapon(weakest, w)
		_casino_result = "Drew: %s  [%s  +%d]  —  replaced %s" % [w.get("name","?"), rname, w.get("damage",0), old]
	_casino_result_win = true
	_refresh_hp(); _rebuild_casino(box)

func _casino_potions(box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(12): return
	var roll = randi() % 10 + 1  # d10
	if roll <= 4:
		_casino_result = "Nothing. Lost 12g."
		_casino_result_win = false
	elif roll <= 7:
		Inventory.add_heal(2)
		_casino_result = "Won 2 potions!"
		_casino_result_win = true
	else:
		Inventory.add_heal(5)
		_casino_result = "JACKPOT — 5 potions!!!"
		_casino_result_win = true
	_refresh_hp(); _rebuild_casino(box)

func _casino_health(box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(35): return
	if randf() < 0.40:
		PlayerStats.increase_max_hp(30)
		_casino_result = "Lucky! +30 max HP!"
		_casino_result_win = true
	else:
		_casino_result = "No luck. Lost 35g."
		_casino_result_win = false
	_refresh_hp(); _rebuild_casino(box)

func _casino_devil(box: VBoxContainer) -> void:
	if not PlayerStats.spend_gold(45): return
	if randf() < 0.50:
		PlayerStats.earn_gold(90)
		PlayerStats.add_luck(5)
		_casino_result = "The Devil smiles. +45g and +5 luck. For now."
		_casino_result_win = true
	else:
		PlayerStats.add_luck(-2)
		_casino_result = "The Devil laughs. Lost 45g and -2 luck."
		_casino_result_win = false
	_refresh_hp(); _rebuild_casino(box)

func _upgrade_top_weapon(bonus: int) -> void:
	if Inventory.weapons.is_empty(): return
	var best = 0
	for i in range(1, Inventory.weapons.size()):
		if Inventory.weapons[i].get("damage", 0) > Inventory.weapons[best].get("damage", 0):
			best = i
	Inventory.weapons[best]["damage"] = Inventory.weapons[best].get("damage", 0) + bonus
	Inventory.emit_signal("inventory_changed")

# ── MARRIAGE ──────────────────────────────────────────────────────────
func _handle_marriage() -> void:
	var tc = Color(0.95, 0.55, 0.75)
	var p  = fate.effect
	type_label.text = "[ A CHANCE MEETING ]"
	type_label.add_theme_color_override("font_color", tc)
	title_label.text = p.get("partner_name", "A Stranger")
	title_label.add_theme_color_override("font_color", tc)
	desc_label.text  = p.get("partner_desc", fate.description)
	flavor_label.text = "\"%s\"" % p.get("partner_quote", fate.flavor)

	var bonus_lbl := Label.new()
	bonus_lbl.text = "Bond: %s" % p.get("bonus_desc", "")
	bonus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus_lbl.add_theme_font_size_override("font_size", 13)
	bonus_lbl.add_theme_color_override("font_color", Color(0.82, 0.65, 0.82))
	action_area.add_child(bonus_lbl)
	action_area.move_child(bonus_lbl, 0)

	var propose_btn := Button.new()
	propose_btn.text = "PROPOSE MARRIAGE"
	propose_btn.custom_minimum_size = Vector2(0, 58)
	propose_btn.add_theme_font_size_override("font_size", 18)
	propose_btn.add_theme_color_override("font_color", tc)
	var sty := StyleBoxFlat.new()
	sty.bg_color     = Color(0.18, 0.06, 0.14)
	sty.border_color = Color(0.85, 0.35, 0.65)
	sty.set_border_width_all(1)
	sty.set_corner_radius_all(4)
	propose_btn.add_theme_stylebox_override("normal", sty)
	propose_btn.pressed.connect(func():
		PlayerStats.marry({
			"name":       p.get("partner_name", ""),
			"bonus_type": p.get("bonus_type", ""),
			"bonus_desc": p.get("bonus_desc", ""),
		})
		desc_label.text = "You exchange vows in the dim corridor light.\n\nWhatever comes next, you face it together."
		flavor_label.text = "\"%s is beside you now.\"" % p.get("partner_name", "Your partner")
		for c in action_area.get_children():
			if c != continue_btn:
				c.queue_free()
		continue_btn.visible = true
	)
	action_area.add_child(propose_btn)
	action_area.move_child(propose_btn, 1)

	var decline_btn := Button.new()
	decline_btn.text = "NOT THE TIME"
	decline_btn.custom_minimum_size = Vector2(0, 42)
	decline_btn.add_theme_font_size_override("font_size", 14)
	decline_btn.add_theme_color_override("font_color", Color(0.5, 0.42, 0.5))
	decline_btn.pressed.connect(_on_continue)
	action_area.add_child(decline_btn)

# ── COMPANION INTERACT ────────────────────────────────────────────────
func _handle_companion_interact() -> void:
	_scroll.offset_bottom = -75.0
	action_area.offset_top = -70.0
	for c in _content.get_children():
		if c is FateArt:
			c.visible = false
			c.custom_minimum_size = Vector2(0, 0)
	desc_label.custom_minimum_size   = Vector2(0, 30)
	flavor_label.custom_minimum_size = Vector2(0, 30)
	var interact_box := VBoxContainer.new()
	interact_box.add_theme_constant_override("separation", 8)
	_content.add_child(interact_box)
	_rebuild_interact(interact_box)
	continue_btn.visible = true

func _rebuild_interact(box: VBoxContainer) -> void:
	for c in box.get_children(): c.queue_free()
	await get_tree().process_frame
	for i in range(CompanionSystem.companions.size()):
		_add_companion_card(box, i, CompanionSystem.companions[i])
	if PlayerStats.is_married():
		_add_partner_card(box)
	if box.get_child_count() == 0:
		var lbl := Label.new()
		lbl.text = "No one to share this moment with — yet."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
		box.add_child(lbl)

func _add_companion_card(box: VBoxContainer, slot: int, c: Dictionary) -> void:
	var tc   = CompanionSystem.type_color(c.get("type", ""))
	var rel  = c.get("relationship", 50)
	var tier = CompanionSystem.get_tier(c)
	var tier_str = "" if tier == 1 else ("  ★ Tier %d" % tier)

	var name_lbl := Label.new()
	name_lbl.text = "%s  —  %s  —  ♥ %d/100%s" % [c.get("name","?"), c.get("type","").to_upper(), rel, tier_str]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", tc)
	box.add_child(name_lbl)

	var passive_lbl := Label.new()
	passive_lbl.text = c.get("passive", "")
	passive_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	passive_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive_lbl.add_theme_font_size_override("font_size", 10)
	passive_lbl.add_theme_color_override("font_color", Color(0.6, 0.58, 0.5))
	box.add_child(passive_lbl)

	if tier >= 2:
		var tier_lbl := Label.new()
		tier_lbl.text = "★★ MAX BOND — passives at full strength!" if tier == 3 else "★ Tier 2 — passives strengthened!"
		tier_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_lbl.add_theme_font_size_override("font_size", 10)
		tier_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2) if tier == 3 else Color(0.85, 0.72, 0.2))
		box.add_child(tier_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 8)
	box.add_child(btn_row)

	var can_potion = Inventory.heal_count > 0
	var p_btn := Button.new()
	p_btn.text = "Give Potion  (+18♥)" if can_potion else "No Potions"
	p_btn.disabled = not can_potion
	p_btn.custom_minimum_size = Vector2(0, 36)
	p_btn.add_theme_font_size_override("font_size", 11)
	p_btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.45))
	var si = slot; var br = box
	p_btn.pressed.connect(func():
		if CompanionSystem.give_item_to(si):
			_refresh_hp(); _rebuild_interact(br)
	)
	btn_row.add_child(p_btn)

	var can_gold = PlayerStats.gold >= 20
	var g_btn := Button.new()
	g_btn.text = "Give 20g  (+12♥)" if can_gold else "Need 20g"
	g_btn.disabled = not can_gold
	g_btn.custom_minimum_size = Vector2(0, 36)
	g_btn.add_theme_font_size_override("font_size", 11)
	g_btn.add_theme_color_override("font_color", Color(0.92, 0.78, 0.2))
	var si2 = slot; var br2 = box
	g_btn.pressed.connect(func():
		if CompanionSystem.give_gold_to(si2, 20):
			_refresh_hp(); _rebuild_interact(br2)
	)
	btn_row.add_child(g_btn)

	var sep := Label.new()
	sep.text = "—  —  —"
	sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sep.add_theme_font_size_override("font_size", 10)
	sep.add_theme_color_override("font_color", Color(0.28, 0.22, 0.28))
	box.add_child(sep)

func _add_partner_card(box: VBoxContainer) -> void:
	var p    = PlayerStats.partner
	var bond = PlayerStats.get_partner_bond()
	var tc   = Color(0.95, 0.55, 0.75)
	var tier = 1 if bond < 75 else (2 if bond < 100 else 3)
	var tier_str = "" if tier == 1 else ("  ♥♥♥ Max Bond" if tier == 3 else "  ♥♥ Deep Bond")

	var name_lbl := Label.new()
	name_lbl.text = "♥  %s  —  %s  —  Bond: %d/100%s" % [p.get("name","?"), p.get("bonus_type","").to_upper(), bond, tier_str]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", tc)
	box.add_child(name_lbl)

	var bonus_lbl := Label.new()
	bonus_lbl.text = p.get("bonus_desc", "")
	bonus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus_lbl.add_theme_font_size_override("font_size", 10)
	bonus_lbl.add_theme_color_override("font_color", Color(0.78, 0.62, 0.78))
	box.add_child(bonus_lbl)

	if tier >= 2:
		var tier_lbl := Label.new()
		tier_lbl.text = "♥♥♥ Eternal Bond — maximum strength reached" if tier == 3 else "♥♥ Deep Bond — enhanced passives active"
		tier_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_lbl.add_theme_font_size_override("font_size", 10)
		tier_lbl.add_theme_color_override("font_color", Color(1.0, 0.75, 0.88) if tier == 3 else Color(0.92, 0.6, 0.78))
		box.add_child(tier_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 8)
	box.add_child(btn_row)

	var can_potion = Inventory.heal_count > 0
	var p_btn := Button.new()
	p_btn.text = "Give Potion  (+20♥)" if can_potion else "No Potions"
	p_btn.disabled = not can_potion
	p_btn.custom_minimum_size = Vector2(0, 36)
	p_btn.add_theme_font_size_override("font_size", 11)
	p_btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.45))
	var br3 = box
	p_btn.pressed.connect(func():
		if PlayerStats.give_potion_to_partner():
			_refresh_hp(); _rebuild_interact(br3)
	)
	btn_row.add_child(p_btn)

	var can_gold = PlayerStats.gold >= 30
	var g_btn := Button.new()
	g_btn.text = "Give 30g  (+15♥)" if can_gold else "Need 30g"
	g_btn.disabled = not can_gold
	g_btn.custom_minimum_size = Vector2(0, 36)
	g_btn.add_theme_font_size_override("font_size", 11)
	g_btn.add_theme_color_override("font_color", Color(0.92, 0.78, 0.2))
	var br4 = box
	g_btn.pressed.connect(func():
		if PlayerStats.give_gold_to_partner(30):
			_refresh_hp(); _rebuild_interact(br4)
	)
	btn_row.add_child(g_btn)

# ── COMBAT ────────────────────────────────────────────────────────────
func _start_combat(effect: Dictionary, win_fight: bool) -> void:
	is_win_fight    = win_fight
	_is_first_strike = true
	enemy_hp    = effect.get("enemy_hp", 30)
	enemy_power = effect.get("enemy_power", 10)
	enemy_label.text    = "%s\nHP: %d" % [effect.get("enemy_name", "Beast"), enemy_hp]
	enemy_label.visible = true
	fight_btn.visible   = true
	_refresh_potion_btn()
	_show_weapon_effects_hint()

func _refresh_potion_btn() -> void:
	var ex = action_area.get_node_or_null("PotionBtn")
	if ex: ex.queue_free()
	if Inventory.heal_count <= 0 or PlayerStats.hp >= PlayerStats.max_hp:
		return
	var btn := Button.new()
	btn.name = "PotionBtn"
	btn.text = "USE POTION  (x%d)  [ +40 HP ]" % Inventory.heal_count
	btn.custom_minimum_size = Vector2(0, 46)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.45))
	var sty2 := StyleBoxFlat.new()
	sty2.bg_color     = Color(0.04, 0.16, 0.07)
	sty2.border_color = Color(0.22, 0.65, 0.28)
	sty2.set_border_width_all(1)
	sty2.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", sty2)
	btn.pressed.connect(func():
		if Inventory.use_heal():
			_refresh_hp()
			_refresh_potion_btn()
	)
	action_area.add_child(btn)
	action_area.move_child(btn, 0)

func _show_weapon_effects_hint() -> void:
	var fx = Inventory.get_weapon_effects()
	var parts: Array = []
	if fx["double_roll"]:     parts.append("Dagger: roll twice")
	if fx["flat_bonus"] > 0:  parts.append("Axe: +%d dmg" % fx["flat_bonus"])
	if fx["reduce_enemy"] > 0:parts.append("Bow: -%d enemy" % fx["reduce_enemy"])
	if fx["first_strike"]:    parts.append("Spear: first strike x2")
	if fx["stun_chance"] > 0: parts.append("Hammer: %.0f%% stun" % (fx["stun_chance"]*100))
	if fx["lifesteal"] > 0:   parts.append("Scythe: lifesteal")
	if fx["dmg_mult"] > 1.0:  parts.append("Greatsword: 1.5x dmg")
	if parts.is_empty(): return
	var lbl := Label.new()
	lbl.text = "  ".join(parts)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.62, 0.58, 0.38))
	action_area.add_child(lbl)
	action_area.move_child(lbl, 0)

func _on_fight() -> void:
	var fx    = Inventory.get_weapon_effects()
	var dodge = CompanionSystem.get_dodge_bonus() + fx["reduce_enemy"]

	# Player roll — daggers roll twice and take the higher
	var p_roll = randi() % 20 + 1
	if fx["double_roll"]:
		p_roll = max(p_roll, randi() % 20 + 1)
	var p = p_roll + PlayerStats.get_combat_power()

	# Hammer stun — enemy skips their counter this round
	var stunned = randf() < fx["stun_chance"]
	var e = 0 if stunned else randi() % 20 + 1 + enemy_power - dodge

	var msg = ""
	if p >= e or stunned:
		var dmg = max(5, p - e + 6)
		# Greatsword multiplier
		dmg = int(dmg * fx["dmg_mult"])
		# Spear first-strike double
		if _is_first_strike and fx["first_strike"]:
			dmg *= 2
			msg = "FIRST STRIKE!  "
		_is_first_strike = false
		if stunned: msg = "STUNNED!  "
		enemy_hp -= dmg
		# Scythe lifesteal
		var steal = int(dmg * fx["lifesteal"])
		if steal > 0:
			PlayerStats.heal(steal)
			_refresh_hp()
			msg += "+%d HP  " % steal
		enemy_label.text = "%s\nHP: %d   %s" % [
			enemy_label.text.split("\n")[0], max(0, enemy_hp), msg]
		if enemy_hp <= 0:
			_combat_victory()
	else:
		var incoming = max(3, e - p + 4) + fx["incoming_penalty"]
		PlayerStats.take_damage(incoming)
		_refresh_hp()
		_refresh_potion_btn()
		if not PlayerStats.is_alive():
			fight_btn.disabled = true
			desc_label.text = "Your strength fails. The darkness takes you."
			await get_tree().create_timer(1.5).timeout
			_check_revive_or_die("combat")

func _combat_victory() -> void:
	fight_btn.visible   = false
	enemy_label.visible = false
	var pb = action_area.get_node_or_null("PotionBtn")
	if pb: pb.queue_free()
	PlayerStats.combat_wins += 1
	var luck_r = fate.effect.get("reward_luck", 0)
	if luck_r > 0: PlayerStats.add_luck(luck_r)
	var gold_r = fate.effect.get("gold_reward", 0)
	if PlayerStats.is_married() and PlayerStats.partner.get("bonus_type", "") == "adventurer":
		gold_r += 5
	if gold_r > 0:
		PlayerStats.earn_gold(gold_r)
		desc_label.text += "\n+%dg" % gold_r
	_refresh_hp()
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
