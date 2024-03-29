class_name Enemy
extends Actor


func _ready():
	if has_node("HPBar"):
		$HPBar.max_value = hp
	

func destroy():
	velocity = Vector2.ZERO
	queue_free()


func damage(amount):
	hp -= amount
	
	if has_node("HPBar"):
		$HPBar.show()
		$HPBar.value = hp
	
	yield(flash_color(), "completed")
	
	if hp <= 0:
		destroy()


func flash_color():
	var flash_timer = Timer.new()
	flash_timer.one_shot = true
	add_child(flash_timer)
	
	$AnimatedSprite.self_modulate = Color(1000, 1000, 1000)
	
	flash_timer.start(0.3)
	yield(flash_timer, "timeout")
	flash_timer.queue_free()
	
	$AnimatedSprite.self_modulate = Color(1, 1, 1)

