extends Node2D

var shop_manager: ShopManager
var map_manager: MapManager
var ui: UI

func _ready() -> void:
	shop_manager = $ShopManager
	map_manager = $MapManager
	map_manager.returned_to_surface.connect(returned_to_surface.bind())
	shop_manager.venture_down.connect(return_to_ground.bind())
	shop_manager.toggle_borrman.connect(toggle_borrman)

func returned_to_surface(drill: Player, collected_ore: int):
	await blackout()
	$UI.visible = false
	$MapManager.visible = false
	shop_manager.open_shop(drill, collected_ore)
	drill.reparent(shop_manager)
	await whiteout()

func blackout():
	var black: Tween = get_tree().create_tween()
	black.tween_property($CanvasModulate, "color", Color.BLACK, 1.0)
	await black.finished

func whiteout():
	var white: Tween = get_tree().create_tween()
	white.tween_property($CanvasModulate, "color", Color.WHITE, 1.0)
	await white.finished

func return_to_ground(drill: Player, available_ore: int):
	await blackout()
	$ShopManager/CameraShop.enabled = false
	$ShopManager.visible = false
	drill.scale = Vector2(0.2, 0.2)
	$UI.visible = true
	$MapManager.visible = true
	drill.reparent(map_manager)
	map_manager.spawn_drill(drill, available_ore)
	await whiteout()
	
func toggle_borrman():
	ui = $UI
	ui.toggle_borrman()
	
