class_name Ore extends Node2D

var game_manager: MapManager

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		game_manager.collect_ore(self)
