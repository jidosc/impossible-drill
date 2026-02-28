class_name UI extends Control

func update_fuel(current, max_fuel):
	$LabelFuel.text = "Fuel: %.1f/%.1f" % [current, max_fuel]
	
func update_ore(current):
	$LabelOre.text = "Ore: %d" % [current]
