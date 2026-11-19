class_name CombatContext
extends RefCounted

var attacker: Node
var defender: Node

var attacker_fight: int
var defender_fight: int

var attacker_body: int
var defender_body: int

var attacker_current_health: int
var defender_current_health: int

var attacker_rot: int
var defender_rot: int

var attacker_bonus_dice: int = 0
var defender_bonus_dice: int = 0

var attacker_total_dice: int
var defender_total_dice: int

var defender_terrain_bonus: int = 0

var attacker_results: Array[String] = []
var defender_results: Array[String] = []
