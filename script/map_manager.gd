class_name MapManager extends Node2D
signal returned_to_surface(player: Player, ore: int)
@export var ui: UI
var packed_ore: PackedScene = preload("res://scenes/ore.tscn")

# Ore types - assign packed scenes in inspector, deeper = rarer
@export var ore_type_1: PackedScene  # TEMP
@export var ore_type_2: PackedScene  # TEMP
@export var ore_type_3: PackedScene  # TEMP
@export var ore_type_4: PackedScene  # TEMP
@export var ore_type_5: PackedScene  # TEMP
@export var ore_type_6: PackedScene  # TEMP
@export var ore_type_7: PackedScene  # TEMP

# Minimum chunk depth required for each ore to start spawning
var ore_1_min_depth := 0   # TEMP
var ore_2_min_depth := 2   # TEMP
var ore_3_min_depth := 4   # TEMP
var ore_4_min_depth := 6   # TEMP
var ore_5_min_depth := 9   # TEMP
var ore_6_min_depth := 12  # TEMP
var ore_7_min_depth := 18  # TEMP

var collected_ore: int = 0
@export var chunk_scene : PackedScene
@export var ore_spawn_ammount := 20.0
var chunks = {}
var chunk_height := 600
var LOAD_DISTANCE := 2
var player: Player

func _process(_delta: float) -> void:
	if player != null:
		var player_y = player.global_position.y
		ui.update_depth(player_y)
		update_chunks(player_y)

func _ready() -> void:
	player = $DrillPlayer
	player.manager = self
	if ui != null:
		player.ui = ui
	var start_chunk = $start_chunk
	chunks[0] = start_chunk
	var surface_offset = 220
	var chunk_rect = Rect2(
		Vector2(start_chunk.position.x, start_chunk.position.y + surface_offset),
		Vector2(600, chunk_height - surface_offset)
	)
	distribute_ore(ore_spawn_ammount, chunk_rect, 0)

func spawn_drill(drill: Player, available_ore: int):
	collected_ore = available_ore
	drill.position = $StartPoint.position
	drill.refuel()
	drill.toggle_trail()
	
	var music: AudioStreamPlayer = $MusicDrilling
	music.pitch_scale = 0.8 + min(drill.speed / 2000.0, 1.0) * 1.0
	music.stream_paused = false
	
func reset_drill(drill: Player):
	$MusicDrilling.stream_paused = true
	returned_to_surface.emit(drill, collected_ore)

func get_available_ores(depth_index: int) -> Array:
	var available = []
	if ore_type_1 and depth_index >= ore_1_min_depth: available.append(ore_type_1)
	if ore_type_2 and depth_index >= ore_2_min_depth: available.append(ore_type_2)
	if ore_type_3 and depth_index >= ore_3_min_depth: available.append(ore_type_3)
	if ore_type_4 and depth_index >= ore_4_min_depth: available.append(ore_type_4)
	if ore_type_5 and depth_index >= ore_5_min_depth: available.append(ore_type_5)
	if ore_type_6 and depth_index >= ore_6_min_depth: available.append(ore_type_6)
	if ore_type_7 and depth_index >= ore_7_min_depth: available.append(ore_type_7)
	# Fallback to default ore if nothing else assigned yet
	if available.is_empty():
		available.append(packed_ore)
	return available

func distribute_ore(amount: int, rect: Rect2, depth_index: int):
	if not amount is int:
		return Error.ERR_INVALID_PARAMETER
	if rect == null:
		rect = $Background.get_rect()
	var available_ores = get_available_ores(depth_index)
	for i in range(amount):
		var random_pos: Vector2 = Vector2(
			randi_range(rect.position.x, rect.position.x + rect.size.x),
			randi_range(rect.position.y, rect.position.y + rect.size.y)
		)
		# Deeper ores are rarer - bias toward common ores with weighted random
		var picked_scene = available_ores[randi_range(0, available_ores.size() - 1)]
		add_ore(random_pos, picked_scene)

func add_ore(at_pos: Vector2, ore_scene: PackedScene = packed_ore):
	var new_ore: Ore = ore_scene.instantiate()
	new_ore.position = at_pos
	new_ore.game_manager = self
	add_child(new_ore)

func collect_ore(ore: Ore, value : int):
	ore.call_deferred("queue_free")
	collected_ore += value
	if ui != null:
		ui.update_ore(collected_ore)

func get_player_chunk(player_y):
	return int(player_y / chunk_height)

func update_chunks(player_y):
	var player_chunk = get_player_chunk(player_y)
	for i in range(max(1, player_chunk - LOAD_DISTANCE), player_chunk + LOAD_DISTANCE):
		if not chunks.has(i):
			spawn_chunk(i)
	cleanup_chunks(player_chunk)

func spawn_chunk(index):
	var chunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.setup(index)
	chunks[index] = chunk
	print("chunk position: ", chunk.position)
	var chunk_rect = Rect2(Vector2(start_chunk_x(), chunk.position.y), Vector2(600, chunk_height))
	print("chunk rect: ", chunk_rect)
	distribute_ore(ore_spawn_ammount, chunk_rect, index)

func start_chunk_x() -> float:
	return $start_chunk.position.x

func cleanup_chunks(player_chunk):
	for index in chunks.keys():
		if abs(index - player_chunk) > LOAD_DISTANCE + 1:
			chunks.erase(index)
