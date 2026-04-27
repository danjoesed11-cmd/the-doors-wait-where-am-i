extends Node

signal stats_changed

var max_hp: int = 100
var hp: int = 100
var round_number: int = 1
var luck: int = 0
var doors_opened: int = 0
var combat_wins: int = 0

func reset() -> void:
	hp = max_hp
	round_number = 1
	luck = 0
	doors_opened = 0
	combat_wins = 0
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

func advance_round() -> void:
	round_number += 1
	doors_opened += 1
	var cs = get_node_or_null("/root/CompanionSystem")
	if cs:
		cs.on_round_survived()
	emit_signal("stats_changed")

func add_luck(amount: int) -> void:
	luck = clamp(luck + amount, -5, 20)
	emit_signal("stats_changed")

func is_alive() -> bool:
	return hp > 0

func get_combat_power() -> int:
	var power = 10 + (combat_wins * 2) + luck
	var inv = get_node_or_null("/root/Inventory")
	var cs  = get_node_or_null("/root/CompanionSystem")
	if inv: power += inv.get_damage_bonus()
	if cs:  power += cs.get_combat_bonus()
	return power
