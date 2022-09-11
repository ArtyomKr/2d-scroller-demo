extends KinematicBody2D

signal hit

onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
export var speed = 400
var screen_size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _physics_process(delta):
	var velocity = Vector2.ZERO
	position.y += delta * gravity
	
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play('run')
		$AnimatedSprite.flip_h = velocity.x < 0
	else: 
		$AnimatedSprite.play('idle')
		
	move_and_slide_with_snap(velocity, Vector2.ZERO, Vector2.UP, !is_on_floor(), 4, 1, false)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


func _on_Player_body_entered():
	$AnimatedSprite.play('die')
	if $AnimatedSprite.animation_finished(): 
		hide()
		emit_signal('hit')
		$CollisionShape2D.set_deferred('disabled', true)
		
		
func start(pos: Vector2):
	position = pos
	show()
	$CollisionShape2D.disabled = false
