extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.039, 0.02, 0.078)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left  = 24
	vbox.offset_right = -24
	vbox.offset_top   = 60
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)

	var title := Label.new()
	title.text = "THE DOORS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	title.custom_minimum_size = Vector2(0, 60)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "Three fates. Three paths. Choose one."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	for i in range(3):
		vbox.add_child(_make_slot_card(i))

	var back_btn := Button.new()
	back_btn.text = "← BACK"
	back_btn.custom_minimum_size = Vector2(0, 52)
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	back_btn.pressed.connect(_on_back)
	vbox.add_child(back_btn)

func _make_slot_card(slot: int) -> PanelContainer:
	var info = SaveManager.get_info(slot)
	var occupied = info.get("valid", false)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 100)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.04, 0.12) if occupied else Color(0.04, 0.02, 0.07)
	style.border_color = Color(0.5, 0.35, 0.1) if occupied else Color(0.25, 0.18, 0.1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	# Left info area
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 6)
	hbox.add_child(info_vbox)

	var slot_label := Label.new()
	slot_label.text = "FILE %d" % (slot + 1)
	slot_label.add_theme_font_size_override("font_size", 18)
	slot_label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2) if occupied else Color(0.4, 0.3, 0.3))
	info_vbox.add_child(slot_label)

	if occupied:
		var round_num  = int(info.get("round_number", 1))
		var hp_val     = int(info.get("hp", 100))
		var max_hp_val = int(info.get("max_hp", 100))
		var luck_val   = int(info.get("luck", 0))

		var detail := Label.new()
		detail.text = "Round %d  ·  HP %d/%d  ·  Luck %d" % [round_num, hp_val, max_hp_val, luck_val]
		detail.add_theme_font_size_override("font_size", 13)
		detail.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45))
		info_vbox.add_child(detail)

		var ts = int(info.get("timestamp", 0))
		if ts > 0:
			var dt = Time.get_datetime_dict_from_unix_time(ts)
			var ts_label := Label.new()
			ts_label.text = "Last played %02d/%02d/%d" % [dt["day"], dt["month"], dt["year"]]
			ts_label.add_theme_font_size_override("font_size", 11)
			ts_label.add_theme_color_override("font_color", Color(0.4, 0.33, 0.33))
			info_vbox.add_child(ts_label)
	else:
		var empty := Label.new()
		empty.text = "Empty  —  Start new game"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", Color(0.35, 0.28, 0.28))
		info_vbox.add_child(empty)

	# Right button area
	var btn_vbox := VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 6)
	btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(btn_vbox)

	var play_btn := Button.new()
	play_btn.text = "CONTINUE" if occupied else "BEGIN"
	play_btn.custom_minimum_size = Vector2(100, 40)
	play_btn.add_theme_font_size_override("font_size", 14)
	play_btn.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	play_btn.pressed.connect(_on_play_slot.bind(slot, occupied))
	btn_vbox.add_child(play_btn)

	if occupied:
		var del_btn := Button.new()
		del_btn.text = "DELETE"
		del_btn.custom_minimum_size = Vector2(100, 32)
		del_btn.add_theme_font_size_override("font_size", 11)
		del_btn.add_theme_color_override("font_color", Color(0.7, 0.25, 0.25))
		del_btn.pressed.connect(_on_delete_slot.bind(slot))
		btn_vbox.add_child(del_btn)

	return panel

func _on_play_slot(slot: int, occupied: bool) -> void:
	if occupied:
		SaveManager.load_slot(slot)
	else:
		PlayerStats.reset()
	GameManager.current_slot = slot
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_delete_slot(slot: int) -> void:
	SaveManager.delete_slot(slot)
	# Rebuild UI to reflect deletion
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame
	_build_ui()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
