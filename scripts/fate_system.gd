extends Node

enum FateType { DEATH, WIN, COMBAT, TRAP, BOON, STORY, WEAPON, COMPANION, ITEM }

class FateData:
	var id: String
	var type: int
	var title: String
	var description: String
	var flavor: String
	var min_round: int
	var max_round: int
	var base_weight: int
	var effect: Dictionary

	func _init(p_id, p_type, p_title, p_desc, p_flavor, p_min, p_max, p_weight, p_effect = {}):
		id = p_id; type = p_type; title = p_title; description = p_desc
		flavor = p_flavor; min_round = p_min; max_round = p_max
		base_weight = p_weight; effect = p_effect

var all_fates: Array = []

func _ready() -> void:
	_register_fates()

func _register_fates() -> void:
	# DEATH
	all_fates.append(FateData.new("death_devoured", FateType.DEATH,
		"DEVOURED", "Something in the dark tears you apart before you can scream.",
		"The darkness had teeth. You never saw it coming.", 3, -1, 8))
	all_fates.append(FateData.new("death_fall", FateType.DEATH,
		"THE FALL", "The floor gives way. You plummet into nothing.",
		"They say you don't feel anything after the first impact.", 2, 12, 6))
	all_fates.append(FateData.new("death_spiked", FateType.DEATH,
		"SPIKED", "Ancient mechanisms spring to life the moment the door swings open.",
		"The trap was set centuries ago. It waited just for you.", 1, 10, 7))
	all_fates.append(FateData.new("death_old_age", FateType.DEATH,
		"OLD AGE", "You have wandered these halls for decades. Time caught you at last.",
		"Generations passed. The doors never ended. You became dust.", 13, -1, 12))
	all_fates.append(FateData.new("death_blade", FateType.DEATH,
		"THE BLADE", "A hooded figure steps from the shadow. A knife catches the light.",
		"You open the door. It smiles. Then nothing.", 4, -1, 6))
	all_fates.append(FateData.new("death_drowned", FateType.DEATH,
		"DROWNED", "The room floods instantly. There is no way out.",
		"The water is cold. Impossibly cold.", 5, -1, 5))

	# WIN
	all_fates.append(FateData.new("win_defeat_satan", FateType.WIN,
		"THE FINAL DOOR", "Satan himself stands in the chamber, wings spread wide. You raise your fists.",
		"The battle shook the foundations of Hell. You walked out alone.",
		10, -1, 5, {"requires_combat": true, "enemy_name": "Satan", "enemy_hp": 80, "enemy_power": 40}))
	all_fates.append(FateData.new("win_angel", FateType.WIN,
		"ASCENSION", "Golden light floods the corridor. Wings unfurl from your back.",
		"You were always meant for something greater. Heaven remembered.", 10, -1, 4))
	all_fates.append(FateData.new("win_royal", FateType.WIN,
		"THE THRONE", "A crown rests on a velvet cushion. A kingdom awaits beyond the door.",
		"Every door you survived was a test. You passed. Long live the king.", 10, -1, 4))

	# COMBAT
	all_fates.append(FateData.new("combat_goblin", FateType.COMBAT,
		"GOBLIN AMBUSH", "A snarling goblin leaps from the shadows with rusted steel.",
		"Small. Vicious. Hungry.", 1, 5, 12,
		{"enemy_name": "Goblin", "enemy_hp": 20, "enemy_power": 6, "reward_luck": 1}))
	all_fates.append(FateData.new("combat_specter", FateType.COMBAT,
		"THE SPECTER", "A wailing ghost drifts toward you, reaching with translucent hands.",
		"It died here, long ago. It wants company.", 2, 7, 10,
		{"enemy_name": "Specter", "enemy_hp": 28, "enemy_power": 10, "reward_luck": 1}))
	all_fates.append(FateData.new("combat_demon", FateType.COMBAT,
		"DEMON GUARD", "A horned demon blocks your path, grinning with too many teeth.",
		"It has been waiting for someone worth killing.", 4, 9, 10,
		{"enemy_name": "Demon", "enemy_hp": 45, "enemy_power": 18, "reward_luck": 2}))
	all_fates.append(FateData.new("combat_vampire", FateType.COMBAT,
		"VAMPIRE LORD", "He steps from darkness, silk coat and gleaming fangs. He bows.",
		"Centuries of hunger. Tonight, he feeds.", 6, 12, 8,
		{"enemy_name": "Vampire Lord", "enemy_hp": 60, "enemy_power": 26, "reward_luck": 2}))
	all_fates.append(FateData.new("combat_dragon", FateType.COMBAT,
		"ANCIENT DRAGON", "The room is a lair. Bones crunch underfoot. The dragon is home.",
		"You can feel its breath before you see it.", 8, -1, 7,
		{"enemy_name": "Ancient Dragon", "enemy_hp": 80, "enemy_power": 35, "reward_luck": 3}))
	all_fates.append(FateData.new("combat_reaper", FateType.COMBAT,
		"THE REAPER", "A skeletal figure in a black robe levels a scythe at your throat.",
		"It whispers your name. It has known this moment for years.", 7, -1, 6,
		{"enemy_name": "Grim Reaper", "enemy_hp": 70, "enemy_power": 30, "reward_luck": 3}))

	# TRAP
	all_fates.append(FateData.new("trap_poison", FateType.TRAP,
		"POISON CLOUD", "Green mist floods the room the moment the door swings open.",
		"You hold your breath. Not long enough.", 1, -1, 10, {"damage": 20}))
	all_fates.append(FateData.new("trap_curse", FateType.TRAP,
		"CURSED CHAMBER", "Dark sigils on every wall begin to glow blood-red.",
		"The curse seeps into your bones like ice.", 3, -1, 8, {"damage": 30, "luck": -2}))
	all_fates.append(FateData.new("trap_hellfire", FateType.TRAP,
		"HELLFIRE", "Jets of fire erupt from the floor in perfect columns.",
		"The heat is unbearable. You barely escape with your life.", 2, -1, 9, {"damage": 25}))
	all_fates.append(FateData.new("trap_void", FateType.TRAP,
		"THE VOID", "The room contains only a swirling black portal. It pulls at you.",
		"Something reaches back when you look inside.", 5, -1, 7, {"damage": 40, "luck": -1}))

	# BOON
	all_fates.append(FateData.new("boon_spring", FateType.BOON,
		"SACRED SPRING", "A glowing pool of silver water shimmers in the center of the room.",
		"You drink deeply. Wounds close. Your mind clears.", 1, -1, 9, {"heal": 35}))
	all_fates.append(FateData.new("boon_armor", FateType.BOON,
		"FORGOTTEN ARMOR", "Ancient armor hangs untouched on the wall. It fits perfectly.",
		"As if it was made for you.", 2, -1, 7, {"heal": 20, "luck": 2}))
	all_fates.append(FateData.new("boon_blessing", FateType.BOON,
		"DIVINE BLESSING", "An angelic presence fills the chamber with warmth and light.",
		"Something watches over you. For now.", 1, -1, 6, {"heal": 50, "luck": 3}))
	all_fates.append(FateData.new("boon_dark_pact", FateType.BOON,
		"DARK PACT", "A small demon sits on a throne of bones. It offers a handshake.",
		"You shake its hand. It smiles too widely. Power flows through you.", 3, -1, 7, {"heal": 15, "luck": 4}))
	all_fates.append(FateData.new("boon_elixir", FateType.BOON,
		"ELIXIR OF LIFE", "A glowing vial rests on a pedestal. It hums with golden energy.",
		"One sip. Full restoration.", 4, -1, 5, {"heal": 100}))

	# STORY
	all_fates.append(FateData.new("story_wanderer", FateType.STORY,
		"THE WANDERER", "A cloaked figure sits beside a dying fire in the center of the room.",
		"\"You've come far,\" he says. \"Most don't make it past the third door.\"", 1, -1, 8))
	all_fates.append(FateData.new("story_mirror", FateType.STORY,
		"THE MIRROR", "An enormous mirror dominates the far wall. Your reflection moves wrong.",
		"It mouths words you cannot hear. Then it grins.", 2, -1, 7, {"luck": 1}))
	all_fates.append(FateData.new("story_librarian", FateType.STORY,
		"THE LIBRARIAN", "A skeleton in robes reads from an endless tome by candlelight.",
		"\"Chapter 4,492,883,\" it murmurs. \"The visitor arrives.\"", 3, -1, 6, {"luck": 1}))
	all_fates.append(FateData.new("story_child", FateType.STORY,
		"THE CHILD", "A small child sits drawing on the stone floor. The drawings are of you.",
		"Every door you've opened. Every fate you've survived. She knew.", 5, -1, 5))
	all_fates.append(FateData.new("story_oracle", FateType.STORY,
		"THE ORACLE", "A blind woman in white robes faces away from you, perfectly still.",
		"\"The doors you fear most,\" she says, \"are the ones that don't kill you.\"", 4, -1, 6, {"luck": 2}))

	# WEAPON
	all_fates.append(FateData.new("weapon_rack", FateType.WEAPON,
		"THE ARMOURY", "An old weapon rack stands against the wall. Something here still has use.",
		"Left by someone who didn't come back for it.", 1, -1, 10, {"min_rarity": 0, "max_rarity": 1}))
	all_fates.append(FateData.new("weapon_chest", FateType.WEAPON,
		"A LOCKED CHEST", "A heavy chest sits open, its lock shattered from inside.",
		"Whatever broke out left something valuable behind.", 3, -1, 8, {"min_rarity": 1, "max_rarity": 3}))
	all_fates.append(FateData.new("weapon_altar", FateType.WEAPON,
		"THE OFFERING ALTAR", "A black stone altar holds a single weapon, offered to no god in particular.",
		"It was placed here deliberately. For you, perhaps.", 6, -1, 6, {"min_rarity": 2, "max_rarity": 4}))
	all_fates.append(FateData.new("weapon_vault", FateType.WEAPON,
		"THE VAULT", "Steel walls. A single pedestal. One weapon left behind by the last survivor.",
		"He did not make it out. Maybe you will.", 9, -1, 4, {"min_rarity": 3, "max_rarity": 5}))
	all_fates.append(FateData.new("weapon_divine", FateType.WEAPON,
		"THE SACRED PEDESTAL", "A shaft of white light falls from nowhere onto a single weapon.",
		"You were not supposed to find this. And yet.", 12, -1, 3, {"min_rarity": 5, "max_rarity": 6}))

	# COMPANION
	all_fates.append(FateData.new("companion_stranger", FateType.COMPANION,
		"A STRANGER", "Someone sits in the corner, watching you with calm eyes.",
		"\"I've been here a while,\" they say. \"I could use the company.\"", 1, -1, 7))
	all_fates.append(FateData.new("companion_wounded", FateType.COMPANION,
		"THE WOUNDED", "A figure slumped against the wall looks up as you enter. Alive. Barely.",
		"\"Help me up,\" they say. \"I'll make it worth your while.\"", 3, -1, 6))
	all_fates.append(FateData.new("companion_cell", FateType.COMPANION,
		"THE PRISONER", "A locked cell. Someone inside rattles the bars when they hear you.",
		"\"Get me out. Whatever you're walking toward — I've survived worse.\"", 2, -1, 5))

	# ITEM
	all_fates.append(FateData.new("item_vial", FateType.ITEM,
		"THE APOTHECARY", "Shelves lined with dusty vials. One still glows faintly.",
		"Someone stocked these for a journey they never finished.", 1, -1, 9, {"count": 1}))
	all_fates.append(FateData.new("item_cache", FateType.ITEM,
		"MEDICINE CACHE", "A whole crate of healing potions, sealed and untouched.",
		"Enough for an army. Or one very unlucky traveller.", 4, -1, 5, {"count": 3}))
	all_fates.append(FateData.new("item_fountain", FateType.ITEM,
		"THE FOUNTAIN", "A bubbling fountain of glowing liquid fills the room with warmth.",
		"You fill every vessel you have. It refills itself before you leave.", 6, -1, 4, {"count": 5}))

func get_three_fates(round_num: int) -> Array:
	var available: Array = []
	for fate in all_fates:
		if fate.min_round <= round_num:
			if fate.max_round == -1 or fate.max_round >= round_num:
				available.append(fate)

	var picked: Array = []
	var used_ids: Array = []

	if round_num >= 10:
		var win_pool = available.filter(func(f): return f.type == FateType.WIN)
		if win_pool.size() > 0:
			var w = _weighted_pick(win_pool, round_num)
			picked.append(w)
			used_ids.append(w.id)

	for _i in range(3 - picked.size()):
		var pool = available.filter(func(f): return f.id not in used_ids)
		if round_num <= 2:
			var safe = pool.filter(func(f): return f.type != FateType.DEATH)
			if safe.size() >= 2:
				pool = safe
		var chosen = _weighted_pick(pool, round_num)
		if chosen:
			picked.append(chosen)
			used_ids.append(chosen.id)

	picked.shuffle()
	return picked

func _weighted_pick(pool: Array, round_num: int):
	if pool.is_empty(): return null
	var weights: Array = []
	var total = 0
	for fate in pool:
		var w = fate.base_weight
		if fate.type == FateType.DEATH:
			w = int(w * (1.0 + round_num * 0.18))
		elif fate.type == FateType.COMBAT:
			w = int(w * (1.0 + round_num * 0.1))
		weights.append(w)
		total += w
	var roll = randi() % total
	var cumulative = 0
	for i in range(pool.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return pool[i]
	return pool[pool.size() - 1]
