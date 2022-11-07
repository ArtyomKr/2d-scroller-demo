class_name Player
extends Actor


signal hit(hp)
signal player_died


export var speed = 300
export var jump_force = 500

enum STATE {
	MOVING,
	IDLE,
	DEAD,
	ATTACKING,
	IS_HIT
}

var screen_size
var _state = STATE.IDLE


func _init():
	hp = 10


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
	manage_state()
	play_animation()


func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func die():
	_state = STATE.DEAD
	$CollisionShape2D.set_deferred('disabled', true)
	get_tree().paused = true
	
	$AnimatedSprite.pause_mode = Node.PAUSE_MODE_PROCESS
	$AnimatedSprite.play('die')
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.stop()
	
	hide()
	emit_signal('player_died')


func damage():
	if $HitTimer.is_stopped():
		$HitTimer.start()
		hp -= 1
		emit_signal('hit', hp)
		if hp <= 0:
			die()


func play_animation():
	var current_animation: String
	
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			current_animation = 'run'
		else: 
			current_animation = 'idle'
	else:
		if velocity.y > 0:
			current_animation = 'fall'
		if velocity.y < -400:
			current_animation = 'jump'

	if _state == STATE.IS_HIT:
		current_animation = 'hurt'
	
	if _state == STATE.ATTACKING:
			current_animation = 'attack'

	if abs(velocity.x) > 0.1:
		$AnimatedSprite.flip_h = velocity.x < 0
	
	if current_animation != $AnimatedSprite.animation:	
		$AnimatedSprite.play(current_animation)


func monitor_attack_input():
	$HitDetector/CollisionShape2D2.set_deferred("disabled", _state != STATE.ATTACKING)
	
	if Input.is_action_just_pressed("attack"):
		if _state != STATE.ATTACKING:
			$AttackTimer.start()


func manage_state():
	if (abs(velocity.x) > 0 || abs(velocity.y) > 0):
		_state = STATE.MOVING
	elif (velocity == Vector2.ZERO):
		_state = STATE.IDLE
		
	if !$AttackTimer.is_stopped():
		_state = STATE.ATTACKING
		
	if !$HitTimer.is_stopped():	
		_state = STATE.IS_HIT



func _on_HitDetector_body_entered(body):
	if body is Enemy:
		body.damage(3)
