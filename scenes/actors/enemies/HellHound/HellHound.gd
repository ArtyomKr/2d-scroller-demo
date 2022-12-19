extends Enemy


signal detected_player


export var speed = 300
export var jump_force = 500

enum STATE {
	IN_AIR,
	IDLE,
	ALERTED,
	DEAD,
	ATTACKING,
	HURT
}

var attack_target
var _state = STATE.IDLE
onready var AlertTimer = $AlertTimer
onready var AttackTimer = $AttackTimer


func _init():
	hp = 10


func _ready():
	hide()


func _physics_process(_delta):
	manage_state()


func start(pos: Vector2):
	position = pos
	show()
	$PhysicsBox.disabled = false


func die():
	_state = STATE.DEAD


func damage(amount):
	#TODO
	.damage(amount)


func manage_state():
	var current_animation: String
	
	match _state:
		STATE.IDLE:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			current_animation = "idle"
		STATE.ALERTED:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if attack_target:
				var target_direction = attack_target.global_position.direction_to(global_position)
				$AnimatedSprite.flip_h = target_direction.x < 0
				
				if AttackTimer.is_stopped():
					_state = STATE.ATTACKING
			
			current_animation = "idle"
		STATE.IN_AIR:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if is_on_floor(): 
				_state = STATE.IDLE
		STATE.ATTACKING:
			print_debug("attack")
			current_animation = "attack"
			AttackTimer.start(rand_range(0.5, 2.0))
		STATE.HURT:
			current_animation = "hurt"
		STATE.DEAD:
			$AnimationPlayer.play("die")
			yield($AnimationPlayer, "animation_finished")
			destroy()
	
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)


func goto_alert():
	_state = STATE.ALERTED


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

