extends Enemy


signal detected_player
export var speed = 300
export var jump_force = 500

var is_attacking = false
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


func _on_DetectionArea_body_entered(body):
	if body is Player:
		emit_signal("detected_player")
		attack(body)


func attack(target: Node):
	var fireball = FireBall.instance()
	var target_direction = target.global_position.direction_to(global_position)
	
	$AnimatedSprite.flip_h = target_direction.x < 0
	
	fireball.global_position = global_position
	fireball.linear_velocity = Vector2(-target_direction.round().x * 300, 0)
	fireball.set_as_toplevel(true)
	
	call_deferred("add_child", fireball)


func _on_HurtBox_area_entered(area):
	pass # Replace with function body.
