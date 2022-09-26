class_name Enemy
extends Actor


func destroy():
	velocity = Vector2.ZERO
	queue_free()


func damage(amount):
	hp -= amount
	if hp <= 0:
		destroy()
