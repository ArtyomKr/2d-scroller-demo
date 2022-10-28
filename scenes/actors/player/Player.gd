class_name Player
extends Actor


signal hit

export var speed = 300
export var jump_force = 500

var screen_size
var is_attacking = false
var is_hit = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _physics_process(delta):
	var direction = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	var movement_speed = direction * speed
	
	velocity.x = movement_speed * delta * 100
	
	if is_on_floor() && Input.is_action_just_pressed('jump'):
		velocity.y -= jump_force
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	monitor_attack_input()
	
	play_animation()


func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func die():
	$AnimatedSprite.play('die')
	if $AnimatedSprite.animation_finished(): 
		hide()
		emit_signal('hit')
		$CollisionShape2D.set_deferred('disabled', true)


func damage():
	is_hit = true
	$AnimatedSprite.play("hurt")
	print('hit')
	emit_signal('hit')


func play_animation():
	var current_animation: String
	
	if is_on_floor():
		if is_attacking:
			current_animation = 'attack'	
		elif abs(velocity.x) > 0.1:
			current_animation = 'run'
		else: 
			current_animation = 'idle'
	else:
		if velocity.y > 0:
			current_animation = 'fall'
		if velocity.y < -400:
			current_animation = 'jump'

	if abs(velocity.x) > 0.1:
		$AnimatedSprite.flip_h = velocity.x < 0
	
	if current_animation != $AnimatedSprite.animation:	
		$AnimatedSprite.play(current_animation)


func monitor_attack_input():
	is_attacking = !$AttackTimer.is_stopped()
	$HitDetector/CollisionShape2D2.set_deferred("disabled", !is_attacking)
	
	if Input.is_action_just_pressed("attack"):
		if !is_attacking:
			$AttackTimer.start()


func _on_HitDetector_body_entered(body):
	if body is Enemy:
		body.damage(3)
		
