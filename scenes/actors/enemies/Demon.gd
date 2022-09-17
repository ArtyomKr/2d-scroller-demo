extends Enemy

signal hit
export var speed = 300
export var jump_force = 500

var is_attacking = false


func _ready():
	hide()


func _physics_process(delta):
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)


func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false

	
	
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

