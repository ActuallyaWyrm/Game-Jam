extends Node2D

enum game { MENU, PLATFORMER }

var locked = false
var escaped = false
var current_game: game = game.MENU
var is_joypad = false

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
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
		
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or InputEventJoypadMotion:
		if (event is InputEventJoypadMotion and abs(event.axis_value) > 0.07) or event is InputEventJoypadButton:
			is_joypad = true
		else:
			is_joypad = false
	elif event is InputEventMouseMotion or InputEventMouseButton or InputEventKey:
		is_joypad = false
