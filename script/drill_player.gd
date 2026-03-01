class_name Player extends CharacterBody2D
@export var ui: UI
@export var drill_sounds: Array[AudioStream]

@onready var screen_size = get_viewport_rect().size
var manager: MapManager
var speed = 100.0
var turn_rate = 0.08
var active = true
var max_fuel = 100
var current_fuel = max_fuel
var fuel_drain_rate = 7.5

var shake_reduction = 1.0
var shake_timer = 0.0
var random_torque = 0.0
var torque_change_timer = 0.0

# Mining trail
var trail: Line2D
const TRAIL_WIDTH = 18.0
const MIN_POINT_DISTANCE = 4.0  # how often to record a new point
var trail_enabled := true

# Rotation clamping
const MAX_ROTATION = PI / 2.0  # 90 degrees
var initial_rotation: float = 0.0
var rotation_locked := false

func _ready() -> void:
	_create_trail()
	initial_rotation = rotation
	start_sounds()

func _create_trail() -> void:
	trail = Line2D.new()
	trail.width = TRAIL_WIDTH
	trail.default_color = Color(0.25, 0.15, 0.05, 1.0)  # dark earthy brown
	trail.joint_mode = Line2D.LINE_JOINT_ROUND
	trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	trail.z_index = 10
	# Give it a rough, dirt-like gradient so edges look like displaced earth
	var grad = Gradient.new()
	grad.set_color(0, Color(0.18, 0.10, 0.03, 1.0))   # dark core
	grad.set_color(1, Color(0.35, 0.22, 0.08, 0.85))  # lighter edge
	trail.gradient = grad
	
	# Add it to the scene root so it stays in world space
	get_tree().root.add_child.call_deferred(trail)
	trail.z_index = -1  # render behind everything

func _physics_process(delta: float) -> void:
	manager.update_chunks(global_position.y)
	if not active:
		return

	#trail.visible = trail_enabled

	# Random torque
	torque_change_timer -= delta
	if torque_change_timer <= 0:
		torque_change_timer = randf_range(0.1 * shake_reduction, 0.3 * shake_reduction)
		random_torque = randf_range(-0.04 / shake_reduction, 0.04 / shake_reduction)

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		rotate(direction * turn_rate)

	rotate(random_torque)

	# Clamp rotation within 90 degrees of starting angle
	var angle_diff = wrapf(rotation - initial_rotation, -PI, PI)
	if abs(angle_diff) > MAX_ROTATION:
		rotation = initial_rotation + clamp(angle_diff, -MAX_ROTATION, MAX_ROTATION)

	var speed_noise = randf_range(0.8, 1.2)
	velocity = Vector2.DOWN.rotated(rotation) * speed * speed_noise * clamp((current_fuel/max_fuel)*10,0,1) 

	shake_timer -= delta
	if shake_timer <= 0:
		shake_timer = randf_range(0.05, 0.15)
		$DrillSprite.position = Vector2(randf_range(-2, 2), randf_range(-2, 2))



	move_and_slide()
	_update_trail()

	current_fuel -= delta * fuel_drain_rate
	if current_fuel <= 0:
		end_travel()
	if ui != null:
		ui.update_fuel(current_fuel, max_fuel)

func drill_ore():
	$AudioDrill.stream = drill_sounds[randi_range(0, len(drill_sounds)-1)] 
	$AudioDrill.play()

func _update_trail() -> void:
	if trail == null or not trail_enabled:
		return
	var world_pos = global_position

	if trail.points.size() == 0:
		trail.points = PackedVector2Array([world_pos])
		return

	var last = trail.points[trail.points.size() - 1]
	if world_pos.distance_to(last) >= MIN_POINT_DISTANCE:
		trail.points = trail.points + PackedVector2Array([world_pos])

func start_travel() -> void:
	toggle_trail()
	initial_rotation = rotation
	rotation_locked = true

func end_travel() -> void:
	toggle_trail()
	await get_tree().create_timer(2).timeout
	active = false
	$DrillSprite.position = Vector2.ZERO
	if manager != null:
		manager.reset_drill(self)
		
func toggle_trail():
	trail_enabled = !trail_enabled
	$CPUParticles2D.emitting = !$CPUParticles2D.emitting
	if trail_enabled:
		# Start a brand new trail segment
		_create_trail()

func start_sounds():
	$AudioDrill2.pitch_scale = 0.4 + speed / 2000
	print($AudioDrill2.pitch_scale)
	$AudioDrill2.play()
	
func stop_sounds():
	$AudioDrill2.stop()


func refuel():
	current_fuel = max_fuel
	active = true

func _on_timer_timeout() -> void:
	$DrillSprite.scale.x = -$DrillSprite.scale.x
	
#A PROCESS TO CLAMP PLAYER INSIDE OF THE CAMERA VIEWPORT
func _process(_delta: float) -> void:
	var margin = 16
	position.x = clamp(position.x, margin, 480 - margin)
