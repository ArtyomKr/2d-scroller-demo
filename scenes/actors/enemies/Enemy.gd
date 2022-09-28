class_name Enemy
extends Actor


func destroy():
	velocity = Vector2.ZERO
	queue_free()


func damage(amount):
	hp -= amount
	
	if hp <= 0:
		destroy()
		
	flash_color()


func flash_color():
	var flash_timer = Timer.new()
	flash_timer.one_shot = true
	add_child(flash_timer)
	
	$AnimatedSprite.self_modulate = Color(2047, 0, 0, 255)
	
	flash_timer.start(0.3)
	yield(flash_timer, "timeout")
	flash_timer.queue_free()
	
	if $AnimatedSprite:
		$AnimatedSprite.self_modulate = Color(1, 1, 1)

