extends Node

signal stats_changed

var max_hp: int = 100
var hp: int = 100
var round_number: int = 1
var luck: int = 0
var doors_opened: int = 0
var combat_wins: int = 0
var gold: int = 0
var partner: Dictionary = {}

func reset() -> void:
	hp = max_hp
	round_number = 1
	luck = 0
	doors_opened = 0
	combat_wins = 0
	gold = 0
	partner = {}
	emit_signal("stats_changed")

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	var cs = get_node_or_null("/root/CompanionSystem")
	if cs:
		cs.on_damage_taken(amount)
	emit_signal("stats_changed")

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	emit_signal("stats_changed")

func increase_max_hp(amount: int) -> void:
	max_hp += amount
	hp = min(max_hp, hp + amount)
	emit_signal("stats_changed")

func advance_round() -> void:
	round_number += 1
	doors_opened += 1
	var cs = get_node_or_null("/root/CompanionSystem")
	if cs:
		cs.on_round_survived()
	_partner_round_effect()
	emit_signal("stats_changed")

func _partner_round_effect() -> void:
	if partner.is_empty():
		return
	match partner.get("bonus_type", ""):
		"healer":
			if round_number % 3 == 0:
				heal(15)
		"scholar":
			if round_number % 5 == 0:
				add_luck(1)

func add_luck(amount: int) -> void:
	luck = clamp(luck + amount, -5, 25)
	emit_signal("stats_changed")

func earn_gold(amount: int) -> void:
	gold += amount
	emit_signal("stats_changed")

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	emit_signal("stats_changed")
	return true

func is_alive() -> bool:
	return hp > 0

func is_married() -> bool:
	return not partner.is_empty()

func marry(p: Dictionary) -> void:
	partner = p.duplicate()
	match partner.get("bonus_type", ""):
		"scholar":    add_luck(3)
		"adventurer": increase_max_hp(10)
	emit_signal("stats_changed")

func get_combat_power() -> int:
	var power = 10 + (combat_wins * 2) + luck
	var inv = get_node_or_null("/root/Inventory")
	var cs  = get_node_or_null("/root/CompanionSystem")
	if inv: power += inv.get_damage_bonus()
	if cs:  power += cs.get_combat_bonus()
	if is_married() and partner.get("bonus_type", "") == "fighter":
		power += 8
	return power
