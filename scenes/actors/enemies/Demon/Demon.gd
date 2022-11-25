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

var is_attacking = false
var target
var _state = STATE.IDLE
const FireBall = preload("res://scenes/Objects/FireBall.tscn")

 
func _init():
	hp = 10


func _ready():
	hide()


func _physics_process(_delta):
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)


func start(pos: Vector2):
	position = pos
	show()
	$PhysicsBox.disabled = false
	
	
func get_animation():
	var current_animation: String
	
	if is_on_floor():
		if is_attacking:
			current_animation = 'breath'	
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
		
	$AnimatedSprite.play(current_animation)


func manage_state(delta):
	var current_animation: String
	
	match _state:
		STATE.IDLE:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

			current_animation = "idle"
			pass
		STATE.ALERTED:
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			
			if target:
				_state = STATE.ATTACKING
				
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
			velocity.x = 0
			
			if target:
				attack(target)
			else:
				 _state = STATE.ALERTED
				
			current_animation = "attack"
		STATE.HURT:
			current_animation = "hurt"
		STATE.DEAD:
			get_tree().paused = true
			$AnimationPlayer.pause_mode = Node.PAUSE_MODE_PROCESS
			$AnimationPlayer.play("die")
			yield($AnimationPlayer, "animation_finished")
			hide()
	
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)


func goto_idle():
	_state = STATE.IDLE


func _on_DetectionArea_body_entered(body):
	if body is Player:
		emit_signal("detected_player")
		target = body
		attack(target)


func attack(target: Node):
	var fireball = FireBall.instance()
	var target_direction = target.global_position.direction_to(global_position)
	
	$AnimatedSprite.flip_h = target_direction.x < 0
	
	fireball.global_position = global_position
	fireball.linear_velocity = Vector2(-target_direction.round().x * 300, 0)
	fireball.set_as_toplevel(true)
	
	call_deferred("add_child", fireball)
