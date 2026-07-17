extends Node2D

enum game { MENU, PLATFORMER }

var locked = false
var escaped = false
var current_game: game = game.MENU

func _process(delta: float) -> void:
	
	
	
	if current_game == game.PLATFORMER and !escaped:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			locked = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		locked = true
	if Input.is_action_just_pressed("ui_cancel"):
		escaped = !escaped
	if current_game == game.PLATFORMER:
		if locked:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
