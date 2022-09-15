class_name Actor
extends KinematicBody2D


onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity.y += delta * gravity
