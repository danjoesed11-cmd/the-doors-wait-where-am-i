extends Control

const DEATH_TITLES = {
	"death_devoured": "DEVOURED", "death_fall": "THE FALL", "death_spiked": "SPIKED",
	"death_old_age": "OLD AGE",  "death_blade": "THE BLADE","death_drowned": "DROWNED",
	"killed": "SLAIN", "trap": "ENSNARED", "combat": "DEFEATED",
}
const WIN_TITLES = {
	"win_defeat_satan": "HELL CONQUEROR", "win_angel": "ASCENDED", "win_royal": "THE CROWNED",
}
const DEATH_SUBS = [
	"The doors claim another soul.",
	"You were so close.",
	"Some doors were never meant to be opened.",
]
const WIN_SUBS = [
	"Your legend echoes through eternity.",
	"The doors bow to you now.",
	"You walked in mortal. You walk out legend.",
]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var result  = GameManager.pending_result
	var outcome = result.get("outcome", "death")
	var is_win  = outcome == "win"

	var title_text = ""
	var sub_text   = ""
	var title_color: Color

	if is_win:
		title_text  = WIN_TITLES.get(result.get("ending", ""), "VICTORY")
		sub_text    = WIN_SUBS[randi() % WIN_SUBS.size()]
		title_color = Color(1.0, 0.85, 0.2)
	else:
		title_text  = DEATH_TITLES.get(result.get("cause", "killed"), "YOU DIED")
		sub_text    = DEATH_SUBS[randi() % DEATH_SUBS.size()]
		title_color = Color(0.85, 0.1, 0.1)

	# Background
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.01, 0.04)
	add_child(bg)

	# Center vbox
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	vbox.custom_minimum_size = Vector2(340, 520)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 26)
	add_child(vbox)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", title_color)
	title.custom_minimum_size = Vector2(340, 110)
	vbox.add_child(title)

	var div := Label.new()
	div.text = "— — — — — — — —"
	div.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	div.add_theme_font_size_override("font_size", 13)
	div.add_theme_color_override("font_color", Color(0.3, 0.2, 0.2))
	vbox.add_child(div)

	var sub := Label.new()
	sub.text = sub_text
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.65, 0.5, 0.5))
	sub.custom_minimum_size = Vector2(340, 56)
	vbox.add_child(sub)

	var rounds := Label.new()
	rounds.text = "Survived %d round%s" % [PlayerStats.round_number, "s" if PlayerStats.round_number != 1 else ""]
	rounds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rounds.add_theme_font_size_override("font_size", 20)
	rounds.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5))
	rounds.custom_minimum_size = Vector2(340, 44)
	vbox.add_child(rounds)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 28)
	vbox.add_child(spacer)

	var btn := Button.new()
	btn.text = "TRY AGAIN"
	btn.custom_minimum_size = Vector2(340, 70)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	btn.pressed.connect(_on_play_again)
	vbox.add_child(btn)

	# Centre the vbox once size is known
	await get_tree().process_frame
	vbox.position = Vector2(size.x / 2.0 - vbox.size.x / 2.0, size.y / 2.0 - vbox.size.y / 2.0)

func _on_play_again() -> void:
	GameManager.start_new_game()
