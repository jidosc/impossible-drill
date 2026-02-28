class_name MapManager extends Node2D

signal returned_to_surface(player: Player)

@export var ui: UI
var packed_ore: PackedScene = preload("res://ore.tscn")
var collected_ore: int = 0

func _ready() -> void:
	distribute_ore(100)
	$DrillPlayer.manager = self
	
func spawn_drill(drill: Player):
	drill.position = $StartPoint.position
	drill.refuel()
	add_child(drill)
	
func reset_drill(drill: Player):
	remove_child(drill)
	returned_to_surface.emit(drill)

func distribute_ore(amount: int):
	if not amount is int:
		return Error.ERR_INVALID_PARAMETER
	for i in range(amount):
		var g_rect: Rect2 = $Background.get_rect()
		print(g_rect)
		var random_pos: Vector2 = Vector2(randi_range($Background.position.x, $Background.position.x + g_rect.size.x), randi_range($Background.position.y, $Background.position.y + g_rect.size.y))
		add_ore(random_pos)

func add_ore(at_pos: Vector2):
	var new_ore: Ore = packed_ore.instantiate()
	new_ore.position = at_pos
	new_ore.game_manager = self
	add_child(new_ore)

func collect_ore(ore: Ore):
	ore.call_deferred("queue_free")
	collected_ore += 1
	ui.update_ore(collected_ore)
