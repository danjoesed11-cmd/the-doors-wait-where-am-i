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
	{"name": "Rogue Quinn",    "type": "scout",   "relationship": 50,
	 "desc": "A thief who made more enemies than friends. She likes the odds in these halls.",
	 "passive": "+6% miss chance on enemies at FAR range."},
	{"name": "Brother Tomas", "type": "healer",  "relationship": 50,
	 "desc": "A monk who lost his monastery to the doors. He tends wounds now instead of praying.",
	 "passive": "Heal 8 HP after every combat victory."},
	{"name": "Archmage Doran","type": "mage",    "relationship": 50,
	 "desc": "He stopped counting spells long ago. The luck just flows now.",
	 "passive": "+5 luck per round. Spells hit harder."},
	{"name": "Iron Knight",   "type": "fighter", "relationship": 50,
	 "desc": "Full plate, no fear, and a very heavy sword. He has opinions about formation.",
	 "passive": "+12 combat power. Reduces incoming damage by 5."},
	{"name": "Mira the Swift","type": "scout",   "relationship": 50,
	 "desc": "Faster than anything she's met in here. So far.",
	 "passive": "+8 dodge chance in combat."},
	{"name": "Grimweld",      "type": "fighter", "relationship": 50,
	 "desc": "A berserker who found peace — sort of — in endless combat.",
	 "passive": "+16 combat power. No other thoughts."},
	{"name": "Sera the Witch","type": "mage",    "relationship": 50,
	 "desc": "She reads futures in the floor cracks. So far, yours looks interesting.",
	 "passive": "+4 luck per round. Curses enemies."},
	{"name": "Old Reg",       "type": "healer",  "relationship": 50,
	 "desc": "A retired battlefield surgeon who simply refused to die.",
	 "passive": "Potions restore +30 extra HP. His recipe."},
]

const TYPE_COLORS = {
	"fighter": Color(0.9, 0.3, 0.2),
	"healer":  Color(0.2, 0.85, 0.4),
	"mage":    Color(0.65, 0.2, 0.9),
	"scout":   Color(0.95, 0.75, 0.1),
}

const TYPE_MAX_HP = {
	"fighter": 80,
	"healer":  50,
	"mage":    45,
	"scout":   55,
}

var companions: Array = []
var _revive_used: bool = false

func _init_hp(c: Dictionary) -> void:
	if not c.has("max_hp"):
		c["max_hp"] = TYPE_MAX_HP.get(c.get("type", ""), 60)
	if not c.has("hp"):
		c["hp"] = c["max_hp"]

func reset() -> void:
	companions.clear()
	_revive_used = false
	emit_signal("companions_changed")

func get_tier(c: Dictionary) -> int:
	var rel = c.get("relationship", 50)
	if rel >= 100: return 3
	if rel >= 75:  return 2
	return 1

func _get_companion(cname: String) -> Dictionary:
	for c in companions:
		if c.get("name") == cname:
			return c
	return {}

func give_item_to(slot: int) -> bool:
	if slot < 0 or slot >= companions.size(): return false
	var inv = get_node_or_null("/root/Inventory")
	if not inv or inv.heal_count <= 0: return false
	inv.heal_count -= 1
	inv.emit_signal("inventory_changed")
	companions[slot]["relationship"] = min(100, companions[slot].get("relationship", 50) + 18)
	emit_signal("companions_changed")
	return true

func give_gold_to(slot: int, amount: int) -> bool:
	if slot < 0 or slot >= companions.size(): return false
	if not PlayerStats.spend_gold(amount): return false
	companions[slot]["relationship"] = min(100, companions[slot].get("relationship", 50) + 12)
	emit_signal("companions_changed")
	return true

func get_random_companion() -> Dictionary:
	var current = companions.map(func(c): return c.get("name", ""))
	var pool = COMPANION_POOL.filter(func(c): return c["name"] not in current)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()].duplicate()

func add_companion(c: Dictionary) -> bool:
	if companions.size() < MAX_COMPANIONS:
		var nc = c.duplicate()
		_init_hp(nc)
		companions.append(nc)
		emit_signal("companions_changed")
		return true
	return false

func replace_companion(slot: int, new_c: Dictionary) -> void:
	var nc = new_c.duplicate()
	_init_hp(nc)
	if slot >= 0 and slot < companions.size():
		companions[slot] = nc
	else:
		companions.append(nc)
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

func heal_companion(slot: int) -> bool:
	if slot < 0 or slot >= companions.size(): return false
	var c  = companions[slot]
	var mh = c.get("max_hp", 60)
	if c.get("hp", mh) >= mh: return false
	var inv = get_node_or_null("/root/Inventory")
	if not inv or inv.heal_count <= 0: return false
	inv.heal_count -= 1
	inv.emit_signal("inventory_changed")
	c["hp"] = min(mh, c.get("hp", 0) + 40)
	emit_signal("companions_changed")
	return true

func all_companions_take_damage(amount: int) -> void:
	for c in companions:
		var mh = c.get("max_hp", TYPE_MAX_HP.get(c.get("type",""), 60))
		if not c.has("hp"): c["hp"] = mh
		c["hp"] = max(0, c["hp"] - amount)
	if not companions.is_empty():
		emit_signal("companions_changed")

func on_round_survived() -> void:
	for c in companions:
		c["relationship"] = min(100, c.get("relationship", 50) + 3)
		var cname : String = c.get("name", "")
		var ctype : String = c.get("type", "")
		if cname == "Sister Mara":
			PlayerStats.heal(8 + (get_tier(c) - 1) * 6)
		elif cname == "Archmage Doran":
			PlayerStats.add_luck(5 + (get_tier(c) - 1) * 2)
		elif cname == "Sera the Witch":
			PlayerStats.add_luck(4 + (get_tier(c) - 1) * 1)
		elif ctype == "mage":
			PlayerStats.add_luck(1)
		# 2 HP regen per round
		var mh : int = c.get("max_hp", TYPE_MAX_HP.get(ctype, 60))
		c["hp"] = min(mh, c.get("hp", mh) + 2)
	emit_signal("companions_changed")

func on_damage_taken(amount: int) -> void:
	if amount >= 20:
		for c in companions:
			c["relationship"] = max(0, c.get("relationship", 50) - 5)
		emit_signal("companions_changed")

func get_combat_bonus() -> int:
	var bonus = 0
	for c in companions:
		var t = get_tier(c)
		match c.get("name", ""):
			"Sir Aldric":     bonus += 8  + (t - 1) * 4
			"Zara the Blade": bonus += 6  + (t - 1) * 3
			"The Iron Wolf":  bonus += 10 + (t - 1) * 5
			"Iron Knight":    bonus += 12 + (t - 1) * 5
			"Grimweld":       bonus += 16 + (t - 1) * 6
			_:
				if c.get("type") == "mage":
					bonus += 2 + (t - 1)
	return bonus

func get_trap_reduction() -> float:
	for c in companions:
		if c.get("type") == "scout":
			return 0.20 + get_tier(c) * 0.10
	return 0.0

func get_dodge_bonus() -> int:
	var bonus : int = 0
	var fox = _get_companion("Shadow Fox")
	if not fox.is_empty():
		bonus += 5 + (get_tier(fox) - 1) * 3
	var mira = _get_companion("Mira the Swift")
	if not mira.is_empty():
		bonus += 8 + (get_tier(mira) - 1) * 3
	return bonus

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
	for c in companions:
		_init_hp(c)
	_revive_used = d.get("revive_used", false)
	emit_signal("companions_changed")
