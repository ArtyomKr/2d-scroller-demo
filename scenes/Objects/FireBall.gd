extends RigidBody2D


func _physics_process(_delta):
	$AnimatedSprite.flip_h = linear_velocity.x > 0


func _on_HitBoxArea_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().damage()
	queue_free()


func _on_DestructionTimer_timeout():
	queue_free()
