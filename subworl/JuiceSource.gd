extends Area2D

func _on_body_entered(body:CharacterBody2D):
	body.emit_signal("give_juice", 20, self)
