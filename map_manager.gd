class_name MapManager extends Node2D

var packed_ore: PackedScene = preload("res://ore.tscn")
var collected_ore: int = 0

func _ready() -> void:
	distribute_ore(100)

func distribute_ore(amount: int):
	if not amount is int:
		return Error.ERR_INVALID_PARAMETER
	for i in range(amount):
		var window_size = get_viewport().get_visible_rect().size
		var random_pos: Vector2 = Vector2(randi_range(0, window_size.x), randi_range(0, window_size.y))
		add_ore(random_pos)
		

func add_ore(at_pos: Vector2):
	var new_ore: Ore = packed_ore.instantiate()
	new_ore.position = at_pos
	new_ore.game_manager = self
	add_child(new_ore)

func collect_ore(ore: Ore):
	ore.call_deferred("queue_free")
	collected_ore += 1
