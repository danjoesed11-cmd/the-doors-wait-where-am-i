extends Node

signal companions_changed

const MAX_COMPANIONS = 2

const COMPANION_POOL = [
	{"name": "Sir Aldric",      "type": "fighter", "relationship": 50,
	 "desc": "A disgraced knight who found purpose in darker halls.",
	 "passive": "+8 combat power. He fights beside you."},
	{"name": "Zara the Blade",  "type": "fighter", "relationship": 50,
	 "desc": "A mercenary who stopped counting the doors long ago.",
	 "passive": "+6 combat power. First strike."},
	{"name": "Sister Mara",     "type": "healer",  "relationship": 50,
	 "desc": "A cleric whose god may or may not still be listening.",
	 "passive": "Heal 10 HP after each round survived."},
	{"name": "Old Henrick",     "type": "healer",  "relationship": 50,
	 "desc": "An herbalist with too many pouches and too much wisdom.",
	 "passive": "Potions restore +20 extra HP."},
	{"name": "Seraphine",       "type": "mage",    "relationship": 50,
	 "desc": "A witch who reads fate in shadows. She likes this place.",
	 "passive": "+3 luck per round."},
	{"name": "The Blind Sage",  "type": "mage",    "relationship": 50,
	 "desc": "He cannot see the doors. He knows what is behind them anyway.",
	 "passive": "+5 luck per round."},
	{"name": "Kira",            "type": "scout",   "relationship": 50,
	 "desc": "A rogue who maps every corridor in her head.",
	 "passive": "Trap damage reduced 30%."},
	{"name": "Shadow Fox",      "type": "scout",   "relationship": 50,
	 "desc": "No one knows his real name. He prefers it that way.",
	 "passive": "+5 dodge in combat."},
	{"name": "The Iron Wolf",   "type": "fighter", "relationship": 50,
	 "desc": "Half man, half something else. All muscle.",
	 "passive": "+10 combat power. Enemies hesitate."},
	{"name": "Lyria the Lost",  "type": "healer",  "relationship": 50,
	 "desc": "She wandered in looking for someone. She stayed.",
	 "passive": "Revive once per run at 20 HP."},
]

const TYPE_COLORS = {
	"fighter": Color(0.9, 0.3, 0.2),
	"healer":  Color(0.2, 0.85, 0.4),
	"mage":    Color(0.65, 0.2, 0.9),
	"scout":   Color(0.95, 0.75, 0.1),
}

var companions: Array = []
var _revive_used: bool = false

func reset() -> void:
	companions.clear()
	_revive_used = false
	emit_signal("companions_changed")

func get_random_companion() -> Dictionary:
	var current = companions.map(func(c): return c.get("name", ""))
	var pool = COMPANION_POOL.filter(func(c): return c["name"] not in current)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()].duplicate()

func add_companion(c: Dictionary) -> bool:
	if companions.size() < MAX_COMPANIONS:
		companions.append(c.duplicate())
		emit_signal("companions_changed")
		return true
	return false

func replace_companion(slot: int, new_c: Dictionary) -> void:
	if slot >= 0 and slot < companions.size():
		companions[slot] = new_c.duplicate()
	else:
		companions.append(new_c.duplicate())
	emit_signal("companions_changed")

func remove_companion(slot: int) -> void:
	if slot >= 0 and slot < companions.size():
		companions.remove_at(slot)
		emit_signal("companions_changed")

func has_companion(cname: String) -> bool:
	for c in companions:
		if c.get("name") == cname:
			return true
	return false

func on_round_survived() -> void:
	for c in companions:
		c["relationship"] = min(100, c.get("relationship", 50) + 4)
		if c.get("name") == "Sister Mara":
			PlayerStats.heal(10)
		elif c.get("type") == "mage":
			PlayerStats.add_luck(1)
	emit_signal("companions_changed")

func on_damage_taken(amount: int) -> void:
	if amount >= 20:
		for c in companions:
			c["relationship"] = max(0, c.get("relationship", 50) - 5)
		emit_signal("companions_changed")

func get_combat_bonus() -> int:
	var bonus = 0
	for c in companions:
		match c.get("name", ""):
			"Sir Aldric":      bonus += 8
			"Zara the Blade":  bonus += 6
			"The Iron Wolf":   bonus += 10
			_:
				if c.get("type") == "mage":
					bonus += 2
	return bonus

func get_trap_reduction() -> float:
	for c in companions:
		if c.get("type") == "scout":
			return 0.30
	return 0.0

func get_dodge_bonus() -> int:
	if has_companion("Shadow Fox"):
		return 5
	return 0

func check_revive() -> bool:
	return not _revive_used and has_companion("Lyria the Lost")

func use_revive() -> void:
	_revive_used = true
	PlayerStats.hp = 20
	emit_signal("companions_changed")

func type_color(t: String) -> Color:
	return TYPE_COLORS.get(t, Color(0.6, 0.6, 0.6))

func to_save() -> Dictionary:
	return {"companions": companions.duplicate(true), "revive_used": _revive_used}

func from_save(d: Dictionary) -> void:
	companions = d.get("companions", [])
	_revive_used = d.get("revive_used", false)
	emit_signal("companions_changed")
