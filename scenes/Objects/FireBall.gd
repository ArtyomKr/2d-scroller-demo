extends RigidBody2D


func _physics_process(delta):
	$AnimatedSprite.flip_h = linear_velocity.x > 0


func _on_FireBall_body_entered(body):
	if body is Player:
		body.damage()
