extends KinematicBody2D

signal hit

onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
export var speed = 270
export var jump_force = 500
var screen_size

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _physics_process(delta):
	var direction = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	var movement_speed = direction * speed
	
	velocity.x = movement_speed * delta * 100
	velocity.y += delta * gravity
	
	if is_on_floor() && Input.is_action_just_pressed('jump'):
		velocity.y -= jump_force
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	
	if velocity.x != 0 && is_on_floor():
		$AnimatedSprite.play('run')
	elif is_on_floor(): 
		$AnimatedSprite.play('idle')
		
	$AnimatedSprite.flip_h = velocity.x < 0
	
	if velocity.y > 0:
		$AnimatedSprite.play('fall')
	if velocity.y < -400:
		$AnimatedSprite.play('jump')
		
	if Input.is_action_just_pressed("attack"):
		$AnimatedSprite.play('attack')
		


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
