class_name Player
extends Actor


signal hit(hp)
signal player_died


export var speed = 300
export var jump_force = 500

enum STATE {
	BLOCKED,
	WALKING,
	JUMPING,
	IN_AIR,
	IDLE,
	DEAD,
	ATTACKING,
	HURT
}

var screen_size
var _state = STATE.IDLE


func _init():
	hp = 10


func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _physics_process(delta):
	manage_state(delta)
	print_debug(_state)


func start(pos: Vector2):
	position = pos
	show()
	$HitBox.disabled = false


func die():
	_state = STATE.DEAD
	$HitBox.set_deferred('disabled', true)
	get_tree().paused = true
	
	$AnimationPlayer.pause_mode = Node.PAUSE_MODE_PROCESS
	$AnimationPlayer.play('die')
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.stop()
	
	hide()
	emit_signal('player_died')


func damage():
	if $HitTaimer .is_stopped():
		$HitTimer.start()
		hp -= 1
		emit_signal('hit', hp)
		if hp <= 0:
			die()


func manage_state(delta):
	var current_animation: String
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var movement_speed = direction * speed
	velocity.x = movement_speed * delta * 100
	
	match _state:
		STATE.BLOCKED:
			pass
		STATE.IDLE:
			if is_on_floor() && abs(direction) > 0:
				_state = STATE.WALKING
			if Input.is_action_just_pressed("attack"):
				_state = STATE.ATTACKING
			if !is_on_floor():
				_state = STATE.IN_AIR
			if is_on_floor() && Input.is_action_just_pressed("jump"):
				velocity.y -= jump_force
				_state = STATE.IN_AIR
			current_animation = "idle_0"
			pass
		STATE.WALKING:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			current_animation = "run"
			
			if Input.is_action_just_pressed("attack"):
				_state = STATE.ATTACKING
			if is_on_floor() && Input.is_action_just_pressed("jump"):
				velocity.y -= jump_force
				_state = STATE.IN_AIR
			if velocity.length() < 1:
				_state = STATE.IDLE
			pass
		STATE.IN_AIR:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if is_on_floor(): 
				_state = STATE.IDLE
			if is_on_floor() && abs(velocity.x) > 0:
				_state = STATE.WALKING
				
			if velocity.y > 0:
				current_animation = "fall"
			else:
				current_animation = "jump"
			pass
		STATE.ATTACKING:
			velocity.x = 0
			current_animation = "attack_0"
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
				
	if abs(velocity.x) > 0.1:
		$Sprite.flip_h = velocity.x < 0
	
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)

func goto_idle():
	_state = STATE.IDLE

func _on_HitDetector_body_entered(body):
	if body is Enemy:
		body.damage(3)
