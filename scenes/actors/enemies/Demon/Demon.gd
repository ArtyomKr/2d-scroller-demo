extends Enemy


signal detected_player


export var speed = 300
export var jump_force = 500

enum STATE {
	TELEPORTING,
	IN_AIR,
	IDLE,
	ALERTED,
	DEAD,
	ATTACKING,
	HURT
}

var attack_target
var teleport_target
var teleport_target_pos
var _state = STATE.IDLE
const FireBall = preload("res://scenes/Objects/FireBall.tscn")
onready var AlertTimer = $AlertTimer
onready var AttackTimer = $AttackTimer
onready var TeleportDelay = $TeleportDelay

 
func _init():
	hp = 10


func _ready():
	hide()


func _physics_process(_delta):
	manage_state()
	print(AlertTimer.time_left)


func start(pos: Vector2):
	position = pos
	show()
	$PhysicsBox.disabled = false


func die():
	_state = STATE.DEAD


func damage(amount):
	_state = STATE.HURT
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
					
			if teleport_target && TeleportDelay.is_stopped():
				_state = STATE.TELEPORTING
				teleport_target_pos = teleport_target.global_position
			
			current_animation = "idle"
		STATE.TELEPORTING:
			current_animation = "teleport"
		STATE.IN_AIR:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if is_on_floor(): 
				_state = STATE.IDLE
			if is_on_floor() && abs(velocity.x) > 0:
				_state = STATE.TELEPORTING
		STATE.ATTACKING:
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
	var fireball = FireBall.instance()
	var target_dir = attack_target.global_position.direction_to(global_position)
		
	$AnimatedSprite.flip_h = target_dir.x < 0
		
	fireball.global_position = global_position - Vector2(25, 0) * target_dir
	fireball.linear_velocity.x = (-target_dir.x / target_dir.abs().x 
	* target_dir.abs().ceil().x * 300)
	fireball.set_as_toplevel(true)

	call_deferred("add_child", fireball)


func teleport():
	if (teleport_target):
		global_position = teleport_target_pos
		TeleportDelay.start()
	_state = STATE.ALERTED


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("detected_player")
		attack_target = body
		teleport_target = null
		_state = STATE.ALERTED
		AlertTimer.stop()


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		teleport_target = attack_target
		attack_target = null
		_state = STATE.ALERTED
		AlertTimer.start()
		TeleportDelay.start()


func _on_AlertTimer_timeout():
	_state = STATE.IDLE
	teleport_target = null
