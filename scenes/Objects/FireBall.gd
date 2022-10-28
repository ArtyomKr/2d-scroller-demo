extends RigidBody2D


func _on_FireBall_body_entered(body):
	if body is Player:
		body.damage()
