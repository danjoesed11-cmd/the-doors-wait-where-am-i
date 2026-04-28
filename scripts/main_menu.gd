extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.039, 0.02, 0.078)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	vbox.custom_minimum_size = Vector2(340, 500)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 22)
	add_child(vbox)

	var title := Label.new()
	title.text = "DOOR OF FATE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	title.custom_minimum_size = Vector2(340, 90)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var divider := Label.new()
	divider.text = "— — — — — — — —"
	divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	divider.add_theme_font_size_override("font_size", 13)
	divider.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))
	vbox.add_child(divider)

	var sub := Label.new()
	sub.text = "Every door has a price."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.65, 0.45, 0.45))
	sub.custom_minimum_size = Vector2(340, 48)
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)

	var play_btn := Button.new()
	play_btn.text = "ENTER THE CORRIDOR"
	play_btn.custom_minimum_size = Vector2(340, 72)
	play_btn.add_theme_font_size_override("font_size", 22)
	play_btn.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	play_btn.pressed.connect(_on_play)
	vbox.add_child(play_btn)

	var quit_btn := Button.new()
	quit_btn.text = "FLEE"
	quit_btn.custom_minimum_size = Vector2(340, 56)
	quit_btn.add_theme_font_size_override("font_size", 17)
	quit_btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)

	await get_tree().process_frame
	vbox.position = Vector2(size.x / 2.0 - vbox.size.x / 2.0, size.y / 2.0 - vbox.size.y / 2.0)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/slot_select.tscn")

func _on_quit() -> void:
	get_tree().quit()
