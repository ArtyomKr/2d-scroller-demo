extends Enemy


signal detected_player


export var walk_speed = 100
export var run_speed = 200
export var jump_force = 500

enum STATE {
	IN_AIR,
	IDLE,
	IDLE_WALK,
	ALERTED,
	ALERTED_CHASE,
	DEAD,
	ATTACKING,
	HURT
}

var attack_target
var direction = 1
var _state = STATE.IDLE
onready var AlertTimer = $AlertTimer
onready var AttackTimer = $AttackTimer


func _init():
	hp = 10


func _ready():
	hide()


func _physics_process(delta):
	manage_state(delta)


func start(pos: Vector2):
	position = pos
	show()
	$PhysicsBox.disabled = false


func die():
	_state = STATE.DEAD


func damage(amount):
	#TODO
	.damage(amount)


func manage_state(delta):
	var current_animation: String
	
	match _state:
		STATE.IDLE:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			current_animation = "idle"
		STATE.IDLE_WALK:
			velocity.x = direction * walk_speed * delta * 100
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			current_animation = "idle_walk"
		STATE.ALERTED:
			current_animation = "alerted_walk"
			
			if attack_target:
				var target_dir = attack_target.global_position.direction_to(global_position)
				target_dir.x = -target_dir.x / target_dir.abs().x
				direction = target_dir.x
				
				if AttackTimer.is_stopped():
					_state = STATE.ATTACKING
				if !AttackTimer.is_stopped():
					velocity.x = run_speed * delta * 100
					current_animation = "run"
				if AlertTimer.is_stopped() && !attack_target:
					_state = STATE.IDLE
			
			velocity.x = direction * walk_speed * delta * 100
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
		STATE.IN_AIR:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if is_on_floor(): 
				_state = STATE.IDLE
		STATE.ATTACKING:
			current_animation = "attack"
			AttackTimer.start(rand_range(0.5, 2.0))
			velocity.x = direction * run_speed * delta * 100
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
		STATE.HURT:
			current_animation = "hurt"
		STATE.DEAD:
			$AnimationPlayer.play("die")
			yield($AnimationPlayer, "animation_finished")
			destroy()
			
	if abs(velocity.x) > 0.1:
		$AnimatedSprite.flip_h = velocity.x > 0
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)


func goto_alert():
	_state = STATE.ALERTED


func goto_idle_walk():
	_state = STATE.IDLE_WALK
	direction = pow(-1, randi() % 2)


func attack():
	var target_dir = attack_target.global_position.direction_to(global_position)
	$AnimatedSprite.flip_h = target_dir.x < 0


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("detected_player")
		attack_target = body
		_state = STATE.ALERTED
		AlertTimer.stop()


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		attack_target = null
		_state = STATE.ALERTED
		AlertTimer.start()


func _on_AlertTimer_timeout():
	_state = STATE.IDLE

