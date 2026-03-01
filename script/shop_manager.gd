class_name ShopManager extends Node2D

signal venture_down(drill: Player)
signal toggle_borrman()

var drill: Player
var available_ore: int = 0
var allowed_to_buy: bool = false
var won: bool = false

func _ready() -> void:
	for c in %Upgrades.get_children():
		var upgrade: Upgrade = c
		upgrade.bought.connect(_upgrade_bought.bind())
		print("connected")

func open_shop(_drill: Player, collected_ore: int):
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	$AudioStreamPlayer.stream_paused = false
	available_ore = collected_ore
	update_ore()
	drill = _drill
	visible = true
	$CameraShop.enabled = true
	drill.position = $DrillPoint.position
	drill.scale = Vector2(0.4, 0.4)
	drill.rotation = 0

func update_ore():
	$con/VBoxContainer/HBoxContainer/LabelOre.text = "Ore: %s" % available_ore 

func _pressed_venture_button():
	$AudioStreamPlayer.stream_paused = true
	venture_down.emit(drill, available_ore)

func _upgrade_bought(upgrade: Upgrade):
	print("bought")
	var cost = upgrade.cost
	if not allowed_to_buy or available_ore < cost:
		return
	available_ore -= cost
	upgrade.cost += ceil(upgrade.cost / 5.0)
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
		"WIFE":
			activate_win_sequence()
		"BORRMAN":
			toggle_borrman.emit()
			
func activate_win_sequence():
	var run_time: int = (Time.get_ticks_msec() - Common.start_ticks) / 1000
	var hours = floor(run_time / 3600)
	var minutes = floor((run_time - hours * 3600) / 60)
	var seconds = run_time - hours * 3600 - minutes * 60
	var time_str: String = ""
	if hours > 0:
		time_str += str(hours)
		if hours > 1:
			time_str += " hours, "
		else:
			time_str += " hour, "
	if minutes > 0:
		time_str += str(minutes)
		if minutes > 1:
			time_str += " minutes, "
		else:
			time_str += " minute, "
	if hours > 0 or minutes > 0:
		time_str += "and %d seconds!" % seconds
	else:
		time_str += "%d seconds!" % seconds
	
	won = true
	$con.hide()
	$Cage.hide()
	
	var sizeup: Tween = get_tree().create_tween()
	sizeup.tween_property($Woman, "scale", Vector2(3.0, 3.0), 1.0)
	await sizeup.finished
	
	$LabelWin.text = "Thank you Fredrik Borrman!\nYou are such a rich man...\nbut what took you so long?\nI have been waiting for\n" + time_str
	$LabelWin.show()
