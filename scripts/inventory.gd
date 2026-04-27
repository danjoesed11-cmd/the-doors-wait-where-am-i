extends Node

signal inventory_changed

const RARITIES = ["Common", "Rare", "Epic", "Legendary", "Mythic", "Hellish", "Godlike"]
const RARITY_COLORS = [
	Color(0.70, 0.70, 0.70),
	Color(0.25, 0.50, 0.95),
	Color(0.65, 0.20, 0.90),
	Color(0.95, 0.65, 0.10),
	Color(0.95, 0.30, 0.20),
	Color(0.70, 0.05, 0.05),
	Color(1.00, 0.95, 0.50),
]
const MAX_WEAPONS = 3

var weapons: Array = []
var heal_count: int = 0

const WEAPON_POOL = [
	{"name": "Rusted Knife",      "rarity": 0, "damage": 3,  "desc": "Worn thin by time. Better than nothing."},
	{"name": "Worn Club",         "rarity": 0, "damage": 4,  "desc": "Crude and heavy. Solves most problems."},
	{"name": "Bone Shard",        "rarity": 0, "damage": 2,  "desc": "Stripped from a skeleton. Still sharp."},
	{"name": "Broken Spear",      "rarity": 0, "damage": 3,  "desc": "Half a spear is still a spear."},
	{"name": "Silver Dagger",     "rarity": 1, "damage": 7,  "desc": "Enchanted silver. Cuts through darkness."},
	{"name": "Iron Mace",         "rarity": 1, "damage": 8,  "desc": "Heavy and honest. Reliable."},
	{"name": "Enchanted Staff",   "rarity": 1, "damage": 6,  "desc": "Hums with old magic. It wants to be used."},
	{"name": "Crossbow",          "rarity": 1, "damage": 9,  "desc": "Distance is survival."},
	{"name": "Dragon Fang",       "rarity": 2, "damage": 14, "desc": "A tooth from a slain dragon. Still warm."},
	{"name": "Shadow Blade",      "rarity": 2, "damage": 12, "desc": "Forged in darkness. It hungers."},
	{"name": "Storm Hammer",      "rarity": 2, "damage": 15, "desc": "Thunder rolls in your grip."},
	{"name": "Soul Ripper",       "rarity": 2, "damage": 13, "desc": "Tears more than flesh."},
	{"name": "Excalibur Shard",   "rarity": 3, "damage": 22, "desc": "A fragment of the true king's blade. Still gleaming."},
	{"name": "Reaper's Scythe",   "rarity": 3, "damage": 20, "desc": "Death itself left this behind."},
	{"name": "Hellfire Sword",    "rarity": 3, "damage": 24, "desc": "The hilt is always warm."},
	{"name": "Void Lance",        "rarity": 3, "damage": 21, "desc": "Punches holes in reality."},
	{"name": "Godslayer",         "rarity": 4, "damage": 35, "desc": "Who made this. Why does it still exist."},
	{"name": "Voidblade",         "rarity": 4, "damage": 32, "desc": "The edge between being and nothing."},
	{"name": "Starfall Axe",      "rarity": 4, "damage": 38, "desc": "Fell from the sky. The crater remains."},
	{"name": "Satan's Pitchfork", "rarity": 5, "damage": 50, "desc": "He dropped it. He noticed."},
	{"name": "Hellfire Brand",    "rarity": 5, "damage": 45, "desc": "It brands your soul as it brands enemies."},
	{"name": "Bone Crusher",      "rarity": 5, "damage": 48, "desc": "Made from the spines of the damned."},
	{"name": "The Eternal Flame", "rarity": 6, "damage": 70, "desc": "Burning since before the universe. It will outlast you."},
	{"name": "Divine Judgment",   "rarity": 6, "damage": 75, "desc": "When you swing this, the heavens watch."},
	{"name": "Heaven's Edge",     "rarity": 6, "damage": 65, "desc": "Forged by angels. Given to you by mistake."},
]

func reset() -> void:
	weapons.clear()
	heal_count = 0
	emit_signal("inventory_changed")

func get_random_weapon(min_r: int = 0, max_r: int = 2) -> Dictionary:
	var pool = WEAPON_POOL.filter(func(w): return w["rarity"] >= min_r and w["rarity"] <= max_r)
	if pool.is_empty():
		pool = WEAPON_POOL.filter(func(w): return w["rarity"] == 0)
	return pool[randi() % pool.size()].duplicate()

func weapon_for_round(round_num: int) -> Dictionary:
	var max_r = clamp(int(round_num / 2.5), 0, 6)
	var min_r = max(0, max_r - 2)
	return get_random_weapon(min_r, max_r)

func add_weapon(w: Dictionary) -> bool:
	if weapons.size() < MAX_WEAPONS:
		weapons.append(w)
		emit_signal("inventory_changed")
		return true
	return false

func replace_weapon(slot: int, new_w: Dictionary) -> void:
	if slot >= 0 and slot < weapons.size():
		weapons[slot] = new_w
	else:
		weapons.append(new_w)
	emit_signal("inventory_changed")

func drop_weapon(slot: int) -> void:
	if slot >= 0 and slot < weapons.size():
		weapons.remove_at(slot)
		emit_signal("inventory_changed")

func add_heal(count: int = 1) -> void:
	heal_count = min(heal_count + count, 9)
	emit_signal("inventory_changed")

func use_heal() -> bool:
	if heal_count <= 0 or PlayerStats.hp >= PlayerStats.max_hp:
		return false
	heal_count -= 1
	var amount = 40
	var cs = get_node_or_null("/root/CompanionSystem")
	if cs and cs.has_companion("Old Henrick"):
		amount += 20
	PlayerStats.heal(amount)
	emit_signal("inventory_changed")
	return true

func get_damage_bonus() -> int:
	var total = 0
	for w in weapons:
		total += w.get("damage", 0)
	return total

func rarity_color(r: int) -> Color:
	return RARITY_COLORS[clamp(r, 0, 6)]

func rarity_name(r: int) -> String:
	return RARITIES[clamp(r, 0, 6)]

func to_save() -> Dictionary:
	return {"weapons": weapons.duplicate(true), "heal_count": heal_count}

func from_save(d: Dictionary) -> void:
	weapons = d.get("weapons", [])
	heal_count = d.get("heal_count", 0)
	emit_signal("inventory_changed")
