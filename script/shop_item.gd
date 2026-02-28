@tool class_name Upgrade extends Panel

@export var description_label: Label
@export var cost_label: Label

@export var description: String = "PLACEHOLDER":
	set(new_desc):
		if description_label != null:
			description_label.text = new_desc
		description = new_desc
	
@export var cost: int = 0:
	set(new_cost):
		if cost_label != null:
			cost_label.text = "Cost: %s" % new_cost
		cost = new_cost
		
@export var type: String = "PLACEHODLER"

signal bought(type: String, cost: int)

func _on_button_pressed() -> void:
	bought.emit(type, cost)
