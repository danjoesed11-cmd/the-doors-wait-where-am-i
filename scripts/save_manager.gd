extends Node

func save_path(slot: int) -> String:
	return "user://save_slot_%d.json" % slot

func save(slot: int) -> void:
	var data = {
		"valid":        true,
		"round_number": PlayerStats.round_number,
		"hp":           PlayerStats.hp,
		"max_hp":       PlayerStats.max_hp,
		"luck":         PlayerStats.luck,
		"combat_wins":  PlayerStats.combat_wins,
		"doors_opened": PlayerStats.doors_opened,
		"timestamp":    Time.get_unix_time_from_system(),
		"inventory":    Inventory.to_save(),
		"companions":   CompanionSystem.to_save(),
	}
	var f = FileAccess.open(save_path(slot), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_slot(slot: int) -> bool:
	var path = save_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return false
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if not data or not data.get("valid", false):
		return false
	PlayerStats.round_number = int(data.get("round_number", 1))
	PlayerStats.hp           = int(data.get("hp", 100))
	PlayerStats.max_hp       = int(data.get("max_hp", 100))
	PlayerStats.luck         = int(data.get("luck", 0))
	PlayerStats.combat_wins  = int(data.get("combat_wins", 0))
	PlayerStats.doors_opened = int(data.get("doors_opened", 0))
	Inventory.from_save(data.get("inventory", {}))
	CompanionSystem.from_save(data.get("companions", {}))
	return true

func get_info(slot: int) -> Dictionary:
	var path = save_path(slot)
	if not FileAccess.file_exists(path):
		return {"valid": false}
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return {"valid": false}
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if not data:
		return {"valid": false}
	return data

func delete_slot(slot: int) -> void:
	var path = save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
