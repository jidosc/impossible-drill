class_name UI extends CanvasLayer

func update_fuel(current, max_fuel):
	%LabelFuel.text = "Fuel: %.1f/%.1f" % [max(0, current), max_fuel]
	%BarFuel.max_value = max_fuel
	%BarFuel.value = current
	
func update_ore(current):
	%LabelOre.text = "Ore: %d" % [current]

func update_depth(current):
	var modified = current / 100
	%LabelDepth.text = "Depth: %dm" % modified

func toggle_borrman():
	%Borrman.visible = !%Borrman.visible
