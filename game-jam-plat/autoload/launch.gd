extends Node2D

enum game { PLATFORMER }

var locked = false
var current_game: game = game.PLATFORMER

func _ready() -> void:
	if current_game == game.PLATFORMER:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			locked = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		locked = !locked
	if current_game == game.PLATFORMER:
		if locked:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
