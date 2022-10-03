extends TextureRect


export (int, 0,100) var value:int = 100 setget set_value
export (int, 0,100) var max_value:int = 100 setget set_max_value


func set_value(hp):
	$MarginContainer/TextureProgress.value = hp
	
	
func set_max_value(max_hp):
	print(max_hp)
	$MarginContainer/TextureProgress.max_value = max_hp
