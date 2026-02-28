extends Camera2D

@export var period = 0.2
@export var magnitude = 90.0
	
func _camera_shake():
	var initial_transform = self.transform 
	var elapsed_time = 0.0
	

	while elapsed_time < period:
		var offset = Vector2(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude)
		)

		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	self.transform = initial_transform
