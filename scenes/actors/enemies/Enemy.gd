extends Actor
class_name Enemy

func destroy():
	velocity = Vector2.ZERO
	queue_free()
