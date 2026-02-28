class_name UI extends Control

func update_fuel(current, max):
	$LabelFuel.text = "Fuel: %.1f/%.1f" % [current, max]
	
func update_ore(current):
	$LabelOre.text = "Ore: %d" % [current]
