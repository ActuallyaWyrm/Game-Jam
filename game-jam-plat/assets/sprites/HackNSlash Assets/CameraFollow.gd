extends Camera2D

@export var fm: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# want the x to follow fisherman, but the y to 
func _process(delta: float) -> void:
	var camPos = global_position
	var fmPos = fm.global_position
	set_position(Vector2(fmPos.x,camPos.y))
