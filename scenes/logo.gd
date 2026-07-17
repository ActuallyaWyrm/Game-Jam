extends Control

var vert_move = 1
var reset_point
var timer = 0
@onready var logo = $TextureRect2

func _ready() -> void:
	$HBoxContainer/VBoxContainer/Button.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if vert_move == 1:
		timer += 1 * delta
		if ceil(logo.position.y) >= 100 and timer > 1:
			vert_move = -1
			timer = 0
		else:
			logo.position.y += 20 * delta
	if vert_move == -1:
		timer += 1 * delta
		if (floor(logo.position.y) >= -100) and timer > 1:
			vert_move = 1
			timer = 0
		else:
			logo.position.y -= 20 * delta
	


func _on_button_pressed() -> void:
	Launch.current_game = Launch.game.PLATFORMER
	get_tree().change_scene_to_file("res://scenes/platformer.tscn")
