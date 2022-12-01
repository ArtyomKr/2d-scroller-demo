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

var target
var _state = STATE.IDLE
const FireBall = preload("res://scenes/Objects/FireBall.tscn")
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
	_state = STATE.HURT
	.damage(amount)


func manage_state():
	var current_animation: String
	
	match _state:
		STATE.IDLE:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			current_animation = "idle"
			pass
		STATE.ALERTED:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if target:
				var target_direction = target.global_position.direction_to(global_position)
				$AnimatedSprite.flip_h = target_direction.x < 0
				
				if AttackTimer.is_stopped():
					_state = STATE.ATTACKING
			elif AlertTimer.is_stopped():
				_state = STATE.IDLE
			
			current_animation = "idle"
			pass
		STATE.TELEPORTING:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			current_animation = "teleport"
			
			pass
		STATE.IN_AIR:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if is_on_floor(): 
				_state = STATE.IDLE
			if is_on_floor() && abs(velocity.x) > 0:
				_state = STATE.TELEPORTING

			pass
		STATE.ATTACKING:
			current_animation = "attack"
			AttackTimer.start(rand_range(0.5, 3.0))
			pass
		STATE.HURT:
			current_animation = "hurt"
			pass
		STATE.DEAD:
			$AnimationPlayer.play("die")
			yield($AnimationPlayer, "animation_finished")
			destroy()
			pass
	
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)


func goto_alert():
	_state = STATE.ALERTED


func attack():
	var fireball = FireBall.instance()
	var target_direction = target.global_position.direction_to(global_position)
		
	$AnimatedSprite.flip_h = target_direction.x < 0
		
	fireball.global_position = global_position - Vector2(25, 0) * target_direction
	fireball.linear_velocity.x = (-target_direction.x / target_direction.abs().x 
	* target_direction.abs().ceil().x * 300)
	fireball.set_as_toplevel(true)

	call_deferred("add_child", fireball)


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("detected_player")
		target = body
		_state = STATE.ALERTED
		AlertTimer.stop()


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		target = null
		_state = STATE.ALERTED
		AlertTimer.start()
