class_name Player extends CharacterBody2D

@export var ui: UI
var manager: MapManager

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const MAX_SPEED = 150
var turn_rate = 0.05

var active = true

const MAX_FUEL = 100
var current_fuel = MAX_FUEL
var fuel_drain_rate = 10


func _physics_process(delta: float) -> void:
	# Handle jump.
	if not active:
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		rotate(direction * turn_rate)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	
	velocity = Vector2.DOWN.rotated(rotation) * SPEED
	move_and_slide()

	current_fuel -= delta * fuel_drain_rate
	if current_fuel <= 0:
		end_travel()
	ui.update_fuel(current_fuel, MAX_FUEL)
	
func start_travel():
	pass

func end_travel():
	active = false
	if manager != null:
		manager.reset_drill(self)

func _on_timer_timeout() -> void:
	$DrillSprite.scale.x = -$DrillSprite.scale.x 
