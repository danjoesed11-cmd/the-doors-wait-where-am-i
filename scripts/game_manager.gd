extends Node

var current_fate   = null
var pending_result: Dictionary = {}
var current_slot:  int = -1

func start_new_game(slot: int = -1) -> void:
	current_slot = slot
	PlayerStats.reset()
	Inventory.reset()
	CompanionSystem.reset()
	_go("game")

func open_door(fate) -> void:
	current_fate = fate
	_go("fate_reveal")

func complete_fate(result: Dictionary) -> void:
	pending_result = result
	match result.get("outcome", ""):
		"death", "win":
			_go("end_screen")
		_:
			PlayerStats.advance_round()
			if current_slot >= 0:
				SaveManager.save(current_slot)
			_go("game")

func _go(scene_name: String) -> void:
	get_tree().change_scene_to_file("res://scenes/" + scene_name + ".tscn")
