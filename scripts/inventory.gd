extends Node

signal inventory_changed

const RARITIES = ["Common","Rare","Epic","Legendary","Mythic","Hellish","Godlike"]
const RARITY_COLORS = [
	Color(0.70,0.70,0.70), Color(0.25,0.50,0.95), Color(0.65,0.20,0.90),
	Color(0.95,0.65,0.10), Color(0.95,0.30,0.20), Color(0.70,0.05,0.05),
	Color(1.00,0.95,0.50),
]
const MAX_WEAPONS = 3

# Weapon type metadata
const WTYPES = {
	"sword":      {"label": "SWORD",      "color": Color(0.72,0.72,0.78), "hint": "Reliable"},
	"dagger":     {"label": "DAGGER",     "color": Color(0.40,0.92,0.55), "hint": "Roll twice"},
	"axe":        {"label": "AXE",        "color": Color(0.92,0.50,0.18), "hint": "+12 flat dmg"},
	"staff":      {"label": "STAFF",      "color": Color(0.45,0.55,0.98), "hint": "+2 pwr/luck"},
	"wand":       {"label": "WAND",       "color": Color(0.78,0.38,0.95), "hint": "+3 pwr/luck"},
	"bow":        {"label": "BOW",        "color": Color(0.40,0.88,0.40), "hint": "-8 enemy roll"},
	"spear":      {"label": "SPEAR",      "color": Color(0.90,0.82,0.28), "hint": "First strike x2"},
	"hammer":     {"label": "HAMMER",     "color": Color(0.80,0.62,0.35), "hint": "30% stun"},
	"scythe":     {"label": "SCYTHE",     "color": Color(0.72,0.28,0.85), "hint": "25% lifesteal"},
	"greatsword": {"label": "GREATSWORD", "color": Color(0.96,0.88,0.30), "hint": "1.5x dmg"},
}

var weapons: Array = []
var heal_count: int = 0

const WEAPON_POOL = [
	# ── COMMON (rarity 0) ───────────────────────────────────────────────
	{"name":"Iron Sword",       "rarity":0,"damage":4, "weapon_type":"sword",
	 "desc":"Heavy and honest. Reliable in any situation."},
	{"name":"Rusted Knife",     "rarity":0,"damage":3, "weapon_type":"dagger",
	 "desc":"Worn thin by time. Strikes twice before the enemy reacts."},
	{"name":"Worn Club",        "rarity":0,"damage":4, "weapon_type":"hammer",
	 "desc":"Crude and heavy. Solves most problems. Sometimes stuns them."},
	{"name":"Bone Shard",       "rarity":0,"damage":3, "weapon_type":"dagger",
	 "desc":"Stripped from a skeleton. Still sharp. Still fast."},
	{"name":"Broken Spear",     "rarity":0,"damage":3, "weapon_type":"spear",
	 "desc":"Half a spear is still a spear. First strike hits harder."},
	{"name":"Hunting Bow",      "rarity":0,"damage":3, "weapon_type":"bow",
	 "desc":"Distance is survival. Keeps the enemy off balance."},
	{"name":"Stone Axe",        "rarity":0,"damage":3, "weapon_type":"axe",
	 "desc":"Heavy as guilt. Adds flat damage on every hit."},
	{"name":"Apprentice Wand",  "rarity":0,"damage":2, "weapon_type":"wand",
	 "desc":"Unpolished magic. Scales sharply with your luck."},

	# ── RARE (rarity 1) ─────────────────────────────────────────────────
	{"name":"Silver Dagger",    "rarity":1,"damage":7, "weapon_type":"dagger",
	 "desc":"Enchanted silver. Cuts through darkness — and rolls twice."},
	{"name":"Iron Mace",        "rarity":1,"damage":8, "weapon_type":"hammer",
	 "desc":"Heavy and honest. Has a real chance of stunning."},
	{"name":"Enchanted Staff",  "rarity":1,"damage":6, "weapon_type":"staff",
	 "desc":"Hums with old magic. Every point of luck fuels it further."},
	{"name":"Crossbow",         "rarity":1,"damage":9, "weapon_type":"bow",
	 "desc":"Distance is survival. Cuts enemy power before they reach you."},
	{"name":"Bastard Sword",    "rarity":1,"damage":10,"weapon_type":"sword",
	 "desc":"Half cavalry blade, half determination. Balanced and deadly."},
	{"name":"Steel Lance",      "rarity":1,"damage":9, "weapon_type":"spear",
	 "desc":"Long reach. Your first blow lands before they're ready."},
	{"name":"War Axe",          "rarity":1,"damage":12,"weapon_type":"axe",
	 "desc":"Built to open armour. Adds flat damage every swing."},
	{"name":"Mystical Wand",    "rarity":1,"damage":7, "weapon_type":"wand",
	 "desc":"Crackles with potential. Triples your luck's power."},
	{"name":"Zweihander",       "rarity":1,"damage":11,"weapon_type":"greatsword",
	 "desc":"Two-handed monster. Hits like a falling wall."},

	# ── EPIC (rarity 2) ─────────────────────────────────────────────────
	{"name":"Dragon Fang",      "rarity":2,"damage":14,"weapon_type":"axe",
	 "desc":"A tooth from a slain dragon. Adds massive flat damage."},
	{"name":"Shadow Blade",     "rarity":2,"damage":12,"weapon_type":"sword",
	 "desc":"Forged in darkness. It hungers. Reliable and quick."},
	{"name":"Storm Hammer",     "rarity":2,"damage":15,"weapon_type":"hammer",
	 "desc":"Thunder rolls in your grip. Stuns with every third swing."},
	{"name":"Soul Ripper",      "rarity":2,"damage":13,"weapon_type":"scythe",
	 "desc":"Tears more than flesh. Steals life with every strike."},
	{"name":"Blade of Sorrow",  "rarity":2,"damage":16,"weapon_type":"sword",
	 "desc":"Every enemy it kills makes it heavier. It still works fine."},
	{"name":"Thunder Spear",    "rarity":2,"damage":16,"weapon_type":"spear",
	 "desc":"The first thrust is supercharged. They never expect it."},
	{"name":"Shadow Bow",       "rarity":2,"damage":14,"weapon_type":"bow",
	 "desc":"Fires from unexpected angles. Enemy barely gets a swing in."},
	{"name":"Arcane Sceptre",   "rarity":2,"damage":13,"weapon_type":"wand",
	 "desc":"Channels pure chaos. Your luck becomes devastating power."},
	{"name":"Giant's Cleaver",  "rarity":2,"damage":18,"weapon_type":"axe",
	 "desc":"Meant for something larger than you. Still works."},
	{"name":"Titan Blade",      "rarity":2,"damage":17,"weapon_type":"greatsword",
	 "desc":"Enormous and brutal. The sheer force floors them."},

	# ── LEGENDARY (rarity 3) ────────────────────────────────────────────
	{"name":"Excalibur Shard",  "rarity":3,"damage":22,"weapon_type":"greatsword",
	 "desc":"A fragment of the true king's blade. Still gleaming."},
	{"name":"Reaper's Scythe",  "rarity":3,"damage":20,"weapon_type":"scythe",
	 "desc":"Death itself left this behind. It feeds you what it takes."},
	{"name":"Hellfire Sword",   "rarity":3,"damage":24,"weapon_type":"greatsword",
	 "desc":"The hilt is always warm. Hits with hellish force."},
	{"name":"Void Lance",       "rarity":3,"damage":21,"weapon_type":"spear",
	 "desc":"Punches holes in reality. First strike hits from another plane."},
	{"name":"Deathbringer",     "rarity":3,"damage":23,"weapon_type":"sword",
	 "desc":"The name is not marketing. Reliable, permanent, inevitable."},
	{"name":"Celestial Bow",    "rarity":3,"damage":22,"weapon_type":"bow",
	 "desc":"Arrows fall from orbit. Enemy barely raises a hand."},
	{"name":"Elder Wand",       "rarity":3,"damage":20,"weapon_type":"wand",
	 "desc":"The original. Your luck becomes almost unfair."},

	# ── MYTHIC (rarity 4) ───────────────────────────────────────────────
	{"name":"Godslayer",        "rarity":4,"damage":35,"weapon_type":"greatsword",
	 "desc":"Who made this. Why does it still exist."},
	{"name":"Voidblade",        "rarity":4,"damage":32,"weapon_type":"sword",
	 "desc":"The edge between being and nothing. Utterly reliable."},
	{"name":"Starfall Axe",     "rarity":4,"damage":38,"weapon_type":"axe",
	 "desc":"Fell from the sky. The crater remains. The flat bonus is enormous."},
	{"name":"Void Staff",       "rarity":4,"damage":30,"weapon_type":"staff",
	 "desc":"Channels the void. Every point of luck echoes twice."},
	{"name":"Shadowstep Dagger","rarity":4,"damage":28,"weapon_type":"dagger",
	 "desc":"Attacks from an angle that doesn't exist. Always rolls twice."},
	{"name":"Titan's Hammer",   "rarity":4,"damage":36,"weapon_type":"hammer",
	 "desc":"Built for giants. Stuns with such violence they forget themselves."},

	# ── HELLISH (rarity 5) ──────────────────────────────────────────────
	{"name":"Satan's Pitchfork","rarity":5,"damage":50,"weapon_type":"spear",
	 "desc":"He dropped it. He noticed. First strike from Hell itself."},
	{"name":"Hellfire Brand",   "rarity":5,"damage":45,"weapon_type":"greatsword",
	 "desc":"It brands your soul as it brands enemies. Massive force."},
	{"name":"Bone Crusher",     "rarity":5,"damage":48,"weapon_type":"hammer",
	 "desc":"Made from the spines of the damned. Stun is near certain."},
	{"name":"Soul Drinker",     "rarity":5,"damage":44,"weapon_type":"scythe",
	 "desc":"Drains their very essence. You feel stronger with every swing."},
	{"name":"Inferno Bow",      "rarity":5,"damage":46,"weapon_type":"bow",
	 "desc":"Arrows made of fire. Enemy barely registers you before they fall."},

	# ── GODLIKE (rarity 6) ──────────────────────────────────────────────
	{"name":"The Eternal Flame","rarity":6,"damage":70,"weapon_type":"staff",
	 "desc":"Burning since before the universe. Luck means everything here."},
	{"name":"Divine Judgment",  "rarity":6,"damage":75,"weapon_type":"greatsword",
	 "desc":"When you swing this, the heavens watch. And applaud."},
	{"name":"Heaven's Edge",    "rarity":6,"damage":65,"weapon_type":"sword",
	 "desc":"Forged by angels. Given to you by mistake. Perfectly balanced."},
	{"name":"Fate's Scythe",    "rarity":6,"damage":68,"weapon_type":"scythe",
	 "desc":"Cuts threads of life directly. You absorb what it severs."},
	{"name":"The Last Arrow",   "rarity":6,"damage":62,"weapon_type":"bow",
	 "desc":"One shot that rewrites the fight before it starts."},
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

# Extra combat power from luck-scaling weapons (staff/wand)
func get_weapon_luck_bonus(luck: int) -> int:
	var extra = 0
	for w in weapons:
		match w.get("weapon_type", "sword"):
			"staff": extra += luck       # doubles luck's contribution
			"wand":  extra += luck * 2   # triples luck's contribution
	return extra

# Returns all active type effects across equipped weapons
func get_weapon_effects() -> Dictionary:
	var fx = {
		"double_roll":      false,
		"flat_bonus":       0,
		"reduce_enemy":     0,
		"first_strike":     false,
		"stun_chance":      0.0,
		"lifesteal":        0.0,
		"dmg_mult":         1.0,
		"incoming_penalty": 0,
	}
	for w in weapons:
		match w.get("weapon_type", "sword"):
			"dagger":
				fx["double_roll"] = true
			"axe":
				fx["flat_bonus"] += 12
			"bow":
				fx["reduce_enemy"] = min(fx["reduce_enemy"] + 8, 18)
			"spear":
				fx["first_strike"] = true
			"hammer":
				fx["stun_chance"] = min(fx["stun_chance"] + 0.30, 0.65)
			"scythe":
				fx["lifesteal"] = max(fx["lifesteal"], 0.25)
			"greatsword":
				fx["dmg_mult"]         = max(fx["dmg_mult"], 1.5)
				fx["incoming_penalty"] += 4
	return fx

func rarity_color(r: int) -> Color:
	return RARITY_COLORS[clamp(r, 0, 6)]

func rarity_name(r: int) -> String:
	return RARITIES[clamp(r, 0, 6)]

func wtype_color(wtype: String) -> Color:
	return WTYPES.get(wtype, WTYPES["sword"])["color"]

func wtype_label(wtype: String) -> String:
	return WTYPES.get(wtype, WTYPES["sword"])["label"]

func wtype_hint(wtype: String) -> String:
	return WTYPES.get(wtype, WTYPES["sword"])["hint"]

func to_save() -> Dictionary:
	return {"weapons": weapons.duplicate(true), "heal_count": heal_count}

func from_save(d: Dictionary) -> void:
	weapons    = d.get("weapons", [])
	heal_count = d.get("heal_count", 0)
	emit_signal("inventory_changed")
