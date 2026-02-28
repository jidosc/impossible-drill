class_name ShopManager extends Node2D

signal venture_down(drill: Player)

var drill: Player

func open_shop(drill: Player):
	self.drill = drill
	$CameraShop.enabled = true
	$ButtonVenture.visible = true
	drill.position = $DrillPoint.position
	add_child(drill)

func _pressed_venture_button():
	$CameraShop.enabled = false
	$ButtonVenture.visible = false
	remove_child(drill)
	venture_down.emit(drill)
