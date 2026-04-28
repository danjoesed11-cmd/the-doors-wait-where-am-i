extends Node

enum FateType { DEATH, WIN, COMBAT, TRAP, BOON, STORY, WEAPON, COMPANION, ITEM, VILLAGE, MARRIAGE, COMPANION_INTERACT }

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
	# ── DEATH ──────────────────────────────────────────────────────────────
	all_fates.append(FateData.new("death_devoured", FateType.DEATH,
		"DEVOURED", "Something in the dark tears you apart before you can scream.",
		"The darkness had teeth. You never saw it coming.", 11, -1, 1))
	all_fates.append(FateData.new("death_fall", FateType.DEATH,
		"THE FALL", "The floor gives way. You plummet into nothing.",
		"They say you don't feel anything after the first impact.", 11, 20, 1))
	all_fates.append(FateData.new("death_spiked", FateType.DEATH,
		"SPIKED", "Ancient mechanisms spring to life the moment the door swings open.",
		"The trap was set centuries ago. It waited just for you.", 11, 18, 1))
	all_fates.append(FateData.new("death_old_age", FateType.DEATH,
		"OLD AGE", "You have wandered these halls for decades. Time caught you at last.",
		"Generations passed. The doors never ended. You became dust.", 40, -1, 2))
	all_fates.append(FateData.new("death_blade", FateType.DEATH,
		"THE BLADE", "A hooded figure steps from the shadow. A knife catches the light.",
		"You open the door. It smiles. Then nothing.", 12, -1, 1))
	all_fates.append(FateData.new("death_drowned", FateType.DEATH,
		"DROWNED", "The room floods instantly. There is no way out.",
		"The water is cold. Impossibly cold.", 14, -1, 1))
	all_fates.append(FateData.new("death_consumed", FateType.DEATH,
		"CONSUMED", "A black mass fills the room from wall to wall. It is hungry.",
		"It does not hate you. It simply needs to eat.", 16, -1, 1))
	all_fates.append(FateData.new("death_petrified", FateType.DEATH,
		"PETRIFIED", "Your legs stop. Then your hands. Then your breath. You become stone.",
		"The next traveller will walk past without knowing what you were.", 20, -1, 1))
	all_fates.append(FateData.new("death_bargain_failed", FateType.DEATH,
		"DEAL BROKEN", "You made a pact you could not honour. The creditor arrives.",
		"The fine print always gets you.", 25, -1, 1))

	# ── WIN (round 40+) ────────────────────────────────────────────────────
	all_fates.append(FateData.new("win_defeat_satan", FateType.WIN,
		"THE FINAL DOOR", "Satan himself stands in the chamber, wings spread wide. You raise your fists.",
		"The battle shook the foundations of Hell. You walked out alone.",
		40, -1, 5, {"requires_combat": true, "enemy_name": "Satan", "enemy_hp": 80, "enemy_power": 40, "gold_reward": 500}))
	all_fates.append(FateData.new("win_angel", FateType.WIN,
		"ASCENSION", "Golden light floods the corridor. Wings unfurl from your back.",
		"You were always meant for something greater. Heaven remembered.", 40, -1, 4))
	all_fates.append(FateData.new("win_royal", FateType.WIN,
		"THE THRONE", "A crown rests on a velvet cushion. A kingdom awaits beyond the door.",
		"Every door you survived was a test. You passed. Long live the king.", 40, -1, 4))

	# ── COMBAT ─────────────────────────────────────────────────────────────
	all_fates.append(FateData.new("combat_goblin", FateType.COMBAT,
		"GOBLIN AMBUSH", "A snarling goblin leaps from the shadows with rusted steel.",
		"Small. Vicious. Hungry.", 1, 5, 12,
		{"enemy_name": "Goblin", "enemy_hp": 20, "enemy_power": 6, "reward_luck": 1, "gold_reward": 8}))
	all_fates.append(FateData.new("combat_specter", FateType.COMBAT,
		"THE SPECTER", "A wailing ghost drifts toward you, reaching with translucent hands.",
		"It died here, long ago. It wants company.", 2, 7, 10,
		{"enemy_name": "Specter", "enemy_hp": 28, "enemy_power": 10, "reward_luck": 1, "gold_reward": 12}))
	all_fates.append(FateData.new("combat_demon", FateType.COMBAT,
		"DEMON GUARD", "A horned demon blocks your path, grinning with too many teeth.",
		"It has been waiting for someone worth killing.", 4, 9, 10,
		{"enemy_name": "Demon", "enemy_hp": 45, "enemy_power": 18, "reward_luck": 2, "gold_reward": 20}))
	all_fates.append(FateData.new("combat_vampire", FateType.COMBAT,
		"VAMPIRE LORD", "He steps from darkness, silk coat and gleaming fangs. He bows.",
		"Centuries of hunger. Tonight, he feeds.", 6, 12, 8,
		{"enemy_name": "Vampire Lord", "enemy_hp": 60, "enemy_power": 26, "reward_luck": 2, "gold_reward": 28}))
	all_fates.append(FateData.new("combat_dragon", FateType.COMBAT,
		"ANCIENT DRAGON", "The room is a lair. Bones crunch underfoot. The dragon is home.",
		"You can feel its breath before you see it.", 8, -1, 7,
		{"enemy_name": "Ancient Dragon", "enemy_hp": 80, "enemy_power": 35, "reward_luck": 3, "gold_reward": 45}))
	all_fates.append(FateData.new("combat_reaper", FateType.COMBAT,
		"THE REAPER", "A skeletal figure in a black robe levels a scythe at your throat.",
		"It whispers your name. It has known this moment for years.", 7, -1, 6,
		{"enemy_name": "Grim Reaper", "enemy_hp": 70, "enemy_power": 30, "reward_luck": 3, "gold_reward": 38}))
	all_fates.append(FateData.new("combat_orc_warlord", FateType.COMBAT,
		"ORC WARLORD", "A mountain of muscle and scar tissue fills the doorway.",
		"It has broken armies. You are one person. It is smiling.", 9, 18, 8,
		{"enemy_name": "Orc Warlord", "enemy_hp": 75, "enemy_power": 26, "reward_luck": 2, "gold_reward": 22}))
	all_fates.append(FateData.new("combat_shadow_assassin", FateType.COMBAT,
		"SHADOW ASSASSIN", "The door opens on an empty room. Then the shadows move.",
		"It was hired specifically. Someone knows you are here.", 12, -1, 7,
		{"enemy_name": "Shadow Assassin", "enemy_hp": 65, "enemy_power": 34, "reward_luck": 3, "gold_reward": 32}))
	all_fates.append(FateData.new("combat_lich_king", FateType.COMBAT,
		"THE LICH KING", "A robed skeleton on a throne of ice raises one finger. An army stirs.",
		"You were not meant to reach this room. Nobody is.", 15, -1, 6,
		{"enemy_name": "Lich King", "enemy_hp": 100, "enemy_power": 36, "reward_luck": 3, "gold_reward": 50}))
	all_fates.append(FateData.new("combat_elder_giant", FateType.COMBAT,
		"ELDER GIANT", "The ceiling rises forty feet. So does the creature standing in the room.",
		"Its footstep shakes the corridor. It has not noticed you yet.", 20, -1, 5,
		{"enemy_name": "Elder Giant", "enemy_hp": 130, "enemy_power": 44, "reward_luck": 4, "gold_reward": 65}))
	all_fates.append(FateData.new("combat_chaos_knight", FateType.COMBAT,
		"CHAOS KNIGHT", "Armour of jagged black steel. A sword that bends light around it. A laugh like breaking glass.",
		"It serves nothing. It simply destroys.", 18, -1, 5,
		{"enemy_name": "Chaos Knight", "enemy_hp": 115, "enemy_power": 40, "reward_luck": 4, "gold_reward": 58}))
	all_fates.append(FateData.new("combat_fallen_angel", FateType.COMBAT,
		"FALLEN ANGEL", "Beautiful. Broken. Its white wings are streaked black. It does not want to fight — but it will.",
		"Something cast it out. You will not be its redemption.", 25, -1, 4,
		{"enemy_name": "Fallen Angel", "enemy_hp": 150, "enemy_power": 48, "reward_luck": 5, "gold_reward": 80}))
	all_fates.append(FateData.new("combat_horned_king", FateType.COMBAT,
		"THE HORNED KING", "The oldest evil in these halls. It has been here since before the halls existed.",
		"It does not rage. It does not threaten. It waits for you to come to it.", 30, -1, 4,
		{"enemy_name": "Horned King", "enemy_hp": 180, "enemy_power": 55, "reward_luck": 5, "gold_reward": 110}))
	all_fates.append(FateData.new("combat_plague_knight", FateType.COMBAT,
		"PLAGUE KNIGHT", "Rot and armor. The room smells of decay before the door opens.",
		"It dies a little every moment. It would like company in that.", 22, -1, 5,
		{"enemy_name": "Plague Knight", "enemy_hp": 140, "enemy_power": 42, "reward_luck": 4, "gold_reward": 70}))

	# ── TRAP ───────────────────────────────────────────────────────────────
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
	all_fates.append(FateData.new("trap_mimic", FateType.TRAP,
		"THE MIMIC", "A chest sits in the center of the room, lid open. Then you see the teeth.",
		"Every chest is a gamble. This one paid out for the chest.", 8, -1, 7, {"damage": 35}))
	all_fates.append(FateData.new("trap_pit", FateType.TRAP,
		"THE PIT", "The floor collapses. You catch a ledge by your fingertips and haul yourself back up.",
		"Your arms scream. You are alive. These two facts are related.", 10, -1, 6, {"damage": 42, "luck": -1}))
	all_fates.append(FateData.new("trap_gauntlet", FateType.TRAP,
		"THE GAUNTLET", "Blades, fire, and iron bars — a corridor that wants you dead.",
		"You sprint through everything. Some of it catches you.", 14, -1, 5, {"damage": 55}))
	all_fates.append(FateData.new("trap_storm", FateType.TRAP,
		"ARCANE STORM", "Lightning erupts from the walls. The air itself is angry.",
		"The scorch marks are from someone before you. They did not make it.", 12, -1, 6, {"damage": 48, "luck": -1}))

	# ── BOON ───────────────────────────────────────────────────────────────
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
	all_fates.append(FateData.new("boon_lucky_find", FateType.BOON,
		"LUCKY FIND", "Something glints from a crack in the stone. You pull it free — a bag of gold coins.",
		"Someone hid this. They are not coming back for it.", 1, -1, 8, {"gold": 25}))
	all_fates.append(FateData.new("boon_golden_cache", FateType.BOON,
		"GOLDEN CACHE", "A hidden compartment behind the wall reveals a fortune.",
		"Their loss. Your gain. Try not to think about that.", 5, -1, 6, {"gold": 60}))
	all_fates.append(FateData.new("boon_champions_hall", FateType.BOON,
		"HALL OF CHAMPIONS", "Portraits of those who walked these halls before you line the walls. Their strength fills you.",
		"You recognise no names. They recognise you.", 10, -1, 6, {"heal": 50, "luck": 2}))
	all_fates.append(FateData.new("boon_dragons_blessing", FateType.BOON,
		"DRAGON'S BLESSING", "A young dragon breathes a thin stream of golden fire over your wounds.",
		"It asks nothing. Perhaps it owes a debt.", 15, -1, 5, {"heal": 40, "max_hp": 20}))
	all_fates.append(FateData.new("boon_treasure_vault", FateType.BOON,
		"TREASURE VAULT", "The door opens on riches beyond counting. You fill your pockets.",
		"Not all fortune kills. Some of it simply waits to be found.", 8, -1, 5, {"gold": 100, "luck": 1}))
	all_fates.append(FateData.new("boon_celestial_pool", FateType.BOON,
		"CELESTIAL POOL", "The water glows white-gold. You immerse yourself completely.",
		"When you emerge, you feel like a different person. A better one.", 20, -1, 4, {"heal": 100, "max_hp": 30, "luck": 2}))

	# ── STORY ──────────────────────────────────────────────────────────────
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
	all_fates.append(FateData.new("story_ghost_army", FateType.STORY,
		"THE FALLEN LEGION", "Hundreds of translucent soldiers march silently through the room, ignoring you.",
		"One turns its head. Nods. Then they are gone.", 15, -1, 4, {"luck": 2}))
	all_fates.append(FateData.new("story_devil_desk", FateType.STORY,
		"THE OFFER", "A suited figure sits at a mahogany desk as if waiting for an appointment.",
		"\"Standard terms,\" it says, sliding a contract across. You decline. It nods respectfully.", 12, -1, 4, {"luck": 3}))
	all_fates.append(FateData.new("story_map_room", FateType.STORY,
		"THE MAP ROOM", "Every door you have ever opened is pinned on a vast map. The pattern makes no sense.",
		"Unless it does, and you simply haven't survived long enough to see it.", 10, -1, 5, {"luck": 1}))
	all_fates.append(FateData.new("story_old_king", FateType.STORY,
		"THE OLD KING", "A withered king sits on a throne made of doors. He has been here longer than the halls.",
		"\"Still going?\" he asks. He sounds genuinely impressed.", 18, -1, 4, {"luck": 2}))
	all_fates.append(FateData.new("story_survivor", FateType.STORY,
		"THE SURVIVOR", "Another traveller. Gaunt, scarred, eyes too wide. They press a coin into your palm.",
		"\"For luck,\" they say. You never see them again.", 6, -1, 5, {"luck": 1}))
	all_fates.append(FateData.new("story_prophecy", FateType.STORY,
		"THE PROPHECY", "Words carved into every wall, ceiling and floor. All the same sentence.",
		"You read it. You fold it into your memory. You move on.", 25, -1, 4, {"luck": 3}))

	# ── WEAPON ─────────────────────────────────────────────────────────────
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

	# ── COMPANION ──────────────────────────────────────────────────────────
	all_fates.append(FateData.new("companion_stranger", FateType.COMPANION,
		"A STRANGER", "Someone sits in the corner, watching you with calm eyes.",
		"\"I've been here a while,\" they say. \"I could use the company.\"", 1, -1, 7))
	all_fates.append(FateData.new("companion_wounded", FateType.COMPANION,
		"THE WOUNDED", "A figure slumped against the wall looks up as you enter. Alive. Barely.",
		"\"Help me up,\" they say. \"I'll make it worth your while.\"", 3, -1, 6))
	all_fates.append(FateData.new("companion_cell", FateType.COMPANION,
		"THE PRISONER", "A locked cell. Someone inside rattles the bars when they hear you.",
		"\"Get me out. Whatever you're walking toward — I've survived worse.\"", 2, -1, 5))

	# ── ITEM ───────────────────────────────────────────────────────────────
	all_fates.append(FateData.new("item_vial", FateType.ITEM,
		"THE APOTHECARY", "Shelves lined with dusty vials. One still glows faintly.",
		"Someone stocked these for a journey they never finished.", 1, -1, 9, {"count": 1}))
	all_fates.append(FateData.new("item_cache", FateType.ITEM,
		"MEDICINE CACHE", "A whole crate of healing potions, sealed and untouched.",
		"Enough for an army. Or one very unlucky traveller.", 4, -1, 5, {"count": 3}))
	all_fates.append(FateData.new("item_fountain", FateType.ITEM,
		"THE FOUNTAIN", "A bubbling fountain of glowing liquid fills the room with warmth.",
		"You fill every vessel you have. It refills itself before you leave.", 6, -1, 4, {"count": 5}))

	# ── VILLAGE ────────────────────────────────────────────────────────────
	all_fates.append(FateData.new("village_market", FateType.VILLAGE,
		"THE MARKET", "A small settlement has sprung up in the corridor. Vendors shout. Children run. It smells of bread.",
		"Somehow, commerce followed you into the dark.", 2, -1, 9, {"village_type": "market"}))
	all_fates.append(FateData.new("village_inn", FateType.VILLAGE,
		"THE CROSSROADS INN", "A tavern. Real ale. A fire that does not want to kill you. You had forgotten what that felt like.",
		"The barkeep asks no questions. You appreciate this deeply.", 3, -1, 7, {"village_type": "inn"}))
	all_fates.append(FateData.new("village_blacksmith", FateType.VILLAGE,
		"THE BLACKSMITH", "The ring of hammer on anvil. A gruff figure in leather looks up from their work.",
		"\"I can make it better,\" they say. \"Or sell you something that already is.\"", 5, -1, 6, {"village_type": "blacksmith"}))
	all_fates.append(FateData.new("village_alchemist", FateType.VILLAGE,
		"THE ALCHEMIST'S CART", "Vials, powders, and things that bubble without heat line the shelves of a creaking cart.",
		"\"Guaranteed to work,\" she says. \"Mostly.\"", 3, -1, 7, {"village_type": "alchemist"}))
	all_fates.append(FateData.new("village_sage", FateType.VILLAGE,
		"THE WANDERING SAGE", "A tattooed elder sits cross-legged, surrounded by floating texts.",
		"\"Knowledge costs,\" he says. \"But ignorance costs more.\"", 8, -1, 5, {"village_type": "sage"}))

	# ── MARRIAGE ───────────────────────────────────────────────────────────
	all_fates.append(FateData.new("marriage_elara", FateType.MARRIAGE,
		"A GENTLE SOUL", "A healer tends to the wounded near a makeshift camp. She looks up when you enter.",
		"\"You look like you need someone watching your back.\"",
		3, -1, 5, {
			"partner_name": "Elara", "bonus_type": "healer",
			"partner_desc": "Elara travels the corridors mending wounds and asking nothing in return. She is steady where others break.",
			"partner_quote": "I go where I'm needed. Maybe that's here.",
			"bonus_desc": "Heals you 15 HP every 3 rounds"
		}))
	all_fates.append(FateData.new("marriage_darian", FateType.MARRIAGE,
		"THE WARRIOR", "A scarred fighter sharpens a blade beside the door. She stands as you enter, eyes level.",
		"\"Been waiting for someone worth fighting beside.\"",
		4, -1, 5, {
			"partner_name": "Daria", "bonus_type": "fighter",
			"partner_desc": "Daria has survived longer than anyone in these corridors. She knows things about staying alive that cannot be taught.",
			"partner_quote": "Side by side. That's the only way.",
			"bonus_desc": "+8 combat power, always"
		}))
	all_fates.append(FateData.new("marriage_mirella", FateType.MARRIAGE,
		"THE SCHOLAR", "Books float in the air around a young woman who does not look up when you enter.",
		"\"The corridors have a logic,\" she says. \"I think I almost understand it.\"",
		5, -1, 5, {
			"partner_name": "Mirella", "bonus_type": "scholar",
			"partner_desc": "Mirella has mapped more of these halls than anyone alive. Her mind is sharper than any blade you'll find.",
			"partner_quote": "Two minds are better than one. I've calculated it.",
			"bonus_desc": "+3 luck now, +1 luck every 5 rounds"
		}))
	all_fates.append(FateData.new("marriage_kael", FateType.MARRIAGE,
		"THE ADVENTURER", "A grinning woman leans against the doorframe as if she owns the place.",
		"\"You're the first interesting person I've met in a hundred doors.\"",
		3, -1, 5, {
			"partner_name": "Kaela", "bonus_type": "adventurer",
			"partner_desc": "Kaela has made a career of finding treasure in terrible places. She has a talent for surviving the unsurvivable and making it look easy.",
			"partner_quote": "Let's see what's behind the next one.",
			"bonus_desc": "+10 max HP now, +5 bonus gold from every combat"
		}))
	all_fates.append(FateData.new("marriage_seraphine", FateType.MARRIAGE,
		"THE WANDERER", "A woman with a hundred roads in her eyes sits on a stack of old maps.",
		"\"I've been to the end of these halls,\" she says quietly. \"I came back for the company.\"",
		6, -1, 4, {
			"partner_name": "Seraphine", "bonus_type": "fighter",
			"partner_desc": "Seraphine has walked every corridor that exists. She fights with the certainty of someone who has already survived everything.",
			"partner_quote": "The worst is already behind us. Probably.",
			"bonus_desc": "+8 combat power, always"
		}))

	# ── COMPANION INTERACT ─────────────────────────────────────────────────
	all_fates.append(FateData.new("camp_quiet", FateType.COMPANION_INTERACT,
		"A QUIET MOMENT", "You and your companions find a sheltered alcove. A fire crackles. No threats. Just warmth.",
		"Some moments are worth stopping for.", 1, -1, 8))
	all_fates.append(FateData.new("camp_fire", FateType.COMPANION_INTERACT,
		"AROUND THE FIRE", "Someone found food. Someone found wine. Your companions gather close and the dark feels further away.",
		"The next door can wait.", 4, -1, 6))
	all_fates.append(FateData.new("camp_vigil", FateType.COMPANION_INTERACT,
		"THE LONG WATCH", "You keep watch together through the dark hours. Words that needed saying finally get said.",
		"Honesty thrives in the dark.", 10, -1, 5))

func get_three_fates(round_num: int) -> Array:
	var married = PlayerStats.is_married()
	var available: Array = []
	for fate in all_fates:
		if fate.min_round > round_num:
			continue
		if fate.max_round != -1 and fate.max_round < round_num:
			continue
		if fate.type == FateType.MARRIAGE and married:
			continue
		if fate.type == FateType.COMPANION_INTERACT:
			if CompanionSystem.companions.is_empty() and not PlayerStats.is_married():
				continue
		available.append(fate)

	var picked: Array = []
	var used_ids: Array = []
	var death_used: bool = false

	if round_num >= 40:
		var win_pool = available.filter(func(f): return f.type == FateType.WIN)
		if win_pool.size() > 0:
			var w = _weighted_pick(win_pool, round_num)
			picked.append(w)
			used_ids.append(w.id)

	for _i in range(3 - picked.size()):
		var pool = available.filter(func(f):
			if f.id in used_ids: return false
			if f.type == FateType.DEATH and death_used: return false
			return true
		)
		if round_num <= 12:
			var safe = pool.filter(func(f): return f.type != FateType.DEATH)
			if safe.size() >= 2:
				pool = safe
		var chosen = _weighted_pick(pool, round_num)
		if chosen:
			picked.append(chosen)
			used_ids.append(chosen.id)
			if chosen.type == FateType.DEATH:
				death_used = true

	picked.shuffle()
	return picked

func _weighted_pick(pool: Array, round_num: int):
	if pool.is_empty(): return null
	var weights: Array = []
	var total = 0
	for fate in pool:
		var w = fate.base_weight
		if fate.type == FateType.DEATH:
			w = int(w * (1.0 + round_num * 0.012))
		elif fate.type == FateType.COMBAT:
			w = int(w * (1.0 + round_num * 0.05))
		weights.append(w)
		total += w
	var roll = randi() % total
	var cumulative = 0
	for i in range(pool.size()):
		cumulative += weights[i]
		if roll < cumulative:
			return pool[i]
	return pool[pool.size() - 1]
