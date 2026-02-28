extends Node2D

var shop_manager: ShopManager
var map_manager: MapManager

func _ready() -> void:
	shop_manager = $ShopManager
	map_manager = $MapManager
	map_manager.returned_to_surface.connect(returned_to_surface.bind())
	shop_manager.venture_down.connect(return_to_ground.bind())

func returned_to_surface(drill: Player):
	shop_manager.open_shop(drill)

func return_to_ground(drill: Player):
	map_manager.spawn_drill(drill)
