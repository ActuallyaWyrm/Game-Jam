extends Node2D

@onready var player := get_parent().get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		position = (player.hook_pos)
