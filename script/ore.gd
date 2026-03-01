class_name Ore extends Node2D

var game_manager: MapManager
@export var value : int
@export var sprite : Texture

func _ready() -> void:
	$Area2D/Sprite2D.texture = sprite

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var camera = get_viewport().get_camera_2d()
		if camera is PlayerCamera:
			camera._camera_shake()
		game_manager.collect_ore(self, value)
		
