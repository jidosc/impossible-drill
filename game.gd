extends Node2D

var shop_manager: ShopManager
var map_manager: MapManager

var collected_ore: int = 0

func _ready() -> void:
	shop_manager = $ShopManager
	map_manager = $MapManager
	map_manager.returned_to_surface.connect(returned_to_surface.bind())
	shop_manager.venture_down.connect(return_to_ground.bind())

func returned_to_surface(drill: Player, collected_ore: int):
	$UI.visible = false
	$MapManager.visible = false
	shop_manager.open_shop(drill, collected_ore)

func return_to_ground(drill: Player, available_ore: int):
	$UI.visible = true
	$MapManager.visible = true
	map_manager.spawn_drill(drill, available_ore)
