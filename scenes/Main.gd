extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/PlayerHPBar.max_value = $Player.hp
	$CanvasLayer/PlayerHPBar.value = $Player.hp
	$Player.start($Player.position)
	$Demon.start($Demon.position)
	$HellHound.start($HellHound.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
