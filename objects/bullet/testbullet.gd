extends CharacterBody2D

func _physics_process(delta):
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if move_and_collide(velocity):
		await get_tree().process_frame
		queue_free()
