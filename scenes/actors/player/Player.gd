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


func start(pos: Vector2):
	position = pos
	show()
	$PhysicsBox.disabled = false


func die():
	_state = STATE.DEAD


func damage():
	hp -= 1
	emit_signal('hit', hp)
	_state = STATE.HURT
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
			velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
			current_animation = "idle_0"
			
			if is_on_floor() && abs(direction) > 0:
				_state = STATE.WALKING
			if Input.is_action_just_pressed("attack"):
				_state = STATE.ATTACKING
			if Input.get_action_strength("ui_down") > 0.3:
				current_animation = "crouch"
			if !is_on_floor():
				_state = STATE.IN_AIR
			if is_on_floor() && Input.is_action_just_pressed("jump"):
				velocity.y -= jump_force
				_state = STATE.IN_AIR
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
		STATE.ATTACKING:
			velocity.x = 0
			current_animation = "attack_0"
		STATE.HURT:
			current_animation = "hurt"
		STATE.DEAD:
			get_tree().paused = true
			$AnimationPlayer.pause_mode = Node.PAUSE_MODE_PROCESS
			$AnimationPlayer.play("die")
			yield($AnimationPlayer, "animation_finished")
			hide()
			emit_signal('player_died')
				
	if abs(velocity.x) > 0.1:
		$Sprite.flip_h = velocity.x < 0
		if direction != 0:
			$HitBoxArea.scale.x = direction
			$PlayerAttackArea.scale.x = direction
	
	if current_animation != $AnimationPlayer.assigned_animation:	
		$AnimationPlayer.play(current_animation)

func goto_idle():
	_state = STATE.IDLE


func _on_PlayerAttackArea_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		area.get_parent().damage(3)
