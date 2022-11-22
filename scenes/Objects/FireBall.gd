extends RigidBody2D


func _physics_process(delta):
	$AnimatedSprite.flip_h = linear_velocity.x > 0


func _on_HitBoxArea_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().damage()
	queue_free()
