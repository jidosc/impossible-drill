extends Control


func _on_button_play_pressed() -> void:
	Common.start_ticks = Time.get_ticks_msec()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
