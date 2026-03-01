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
	drill.scale = Vector2(0.4, 0.4)
	drill.rotation = 0

func update_ore():
	$MarginContainer/VBoxContainer/HBoxContainer/LabelOre.text = "Ore: %s" % available_ore 

func _pressed_venture_button():
	venture_down.emit(drill, available_ore)

func _upgrade_bought(upgrade: Upgrade):
	print("bought")
	var cost = upgrade.cost
	if available_ore < cost:
		return
	available_ore -= cost
	upgrade.cost += 1
	update_ore()
	match upgrade.type:
		"FUEL":
			drill.max_fuel += 15
		"TURN":
			drill.turn_rate += 0.2
		"SPEED":
			drill.speed += 15
		"SHAKE":
			drill.shake_reduction += 0.1
			
