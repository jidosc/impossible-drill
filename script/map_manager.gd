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


func _process(_delta: float) -> void:
	if player != null:
		var player_y = player.global_position.y
		update_chunks(player_y)
		
		
func _ready() -> void:
	player = $DrillPlayer
	player.manager = self
	if ui != null:
		player.ui = ui
	var start_chunk = $start_chunk
	chunks[0] = start_chunk
	
func spawn_drill(drill: Player, available_ore: int):
	collected_ore = available_ore
	drill.position = $StartPoint.position
	drill.refuel()
	drill.trail_enabled = true
	add_child(drill)
	
func reset_drill(drill: Player):
	returned_to_surface.emit(drill, collected_ore)

func distribute_ore(amount: int, rect : Rect2):
	if not amount is int:
		return Error.ERR_INVALID_PARAMETER
	if rect == null:
		rect = $Background.get_rect()
	for i in range(amount):
		#print(g_rect)
		var random_pos :Vector2 = Vector2(
			randi_range(rect.position.x, rect.position.x + rect.size.x),
			randi_range(rect.position.y, rect.position.y + rect.size.y)
		)
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
	for i in range(max(1,player_chunk - LOAD_DISTANCE),player_chunk + LOAD_DISTANCE):
		if not chunks.has(i):
			spawn_chunk(i)
	cleanup_chunks(player_chunk)
	
func spawn_chunk(index):
	var chunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.setup(index)
	chunks[index] = chunk
	var chunk_rect = Rect2(chunk.position,Vector2(400,chunk_height))
	distribute_ore(50,chunk_rect)
	
func cleanup_chunks(player_chunk):
	for index in chunks.keys():
		if abs(index - player_chunk) > LOAD_DISTANCE + 1:
			chunks.erase(index)
