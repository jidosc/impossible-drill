class_name MapManager extends Node2D

signal returned_to_surface(player: Player, ore: int)

@export var ui: UI
var packed_ore: PackedScene = preload("res://scenes/ore.tscn")
var collected_ore: int = 0
@export var chunk_scene : PackedScene
var chunks = {}
var chunk_height := 600
var LOAD_DISTANCE := 2
var player: Player


func _process(delta: float) -> void:
	if player != null:
		var player_y = player.global_position.y
		update_chunks(player_y)
		print(get_player_chunk(player_y))
		
		
func _ready() -> void:
	distribute_ore(100)
	player = $DrillPlayer
	player.manager = self
	if ui != null:
		player.ui = ui
	
func spawn_drill(drill: Player, available_ore: int):
	collected_ore = available_ore
	drill.position = $StartPoint.position
	drill.refuel()
	add_child(drill)
	
func reset_drill(drill: Player):
	remove_child(drill)
	returned_to_surface.emit(drill, collected_ore)

func distribute_ore(amount: int):
	if not amount is int:
		return Error.ERR_INVALID_PARAMETER
	for i in range(amount):
		var g_rect: Rect2 = $Background.get_rect()
		#print(g_rect)
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
	if ui != null:
		ui.update_ore(collected_ore)
	
func get_player_chunk(player_y):
	return int(player_y/chunk_height)
	
func update_chunks(player_y):
	var player_chunk = get_player_chunk(player_y)
	for i in range(player_chunk - LOAD_DISTANCE,player_chunk + LOAD_DISTANCE):
		if not chunks.has(i):
			spawn_chunk(i)
	cleanup_chunks(player_chunk)
	
func spawn_chunk(index):
	var chunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.setup(index)
	chunks[index] = chunk
	
func cleanup_chunks(player_chunk):
	for index in chunks.keys():
		if abs(index - player_chunk) > LOAD_DISTANCE + 1:
			chunks.erase(index)
