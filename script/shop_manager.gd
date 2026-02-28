class_name ShopManager extends Node2D

signal venture_down(drill: Player)

var drill: Player
var available_ore: int = 0

func _ready() -> void:
	for c in %Upgrades.get_children():
		var upgrade: Upgrade = c
		upgrade.bought.connect(_upgrade_bought.bind())
		print("connected")

func open_shop(_drill: Player, collected_ore: int):
	available_ore = collected_ore
	update_ore()
	
	drill = _drill
	visible = true
	$CameraShop.enabled = true
	drill.position = $DrillPoint.position
	add_child(drill)

func update_ore():
	$MarginContainer/VBoxContainer/LabelOre.text = "Ore: %s" % available_ore 

func _pressed_venture_button():
	$CameraShop.enabled = false
	visible = false
	remove_child(drill)
	venture_down.emit(drill, available_ore)

func _upgrade_bought(type: String, cost: int):
	print("bought")
	if available_ore < cost:
		return
	available_ore -= cost
	update_ore()
	match type:
		"FUEL":
			drill.max_fuel += 10
		"TURN":
			drill.turn_rate += 0.1
		"SPEED":
			drill.speed += 10
			
