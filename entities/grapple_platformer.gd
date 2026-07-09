extends CharacterBody2D

@export var speed = 50
@export var rope_length = 500
@export var grav = 100

var hook_pos = Vector2()
var current_rope_length
var launched = false
var hooked = false

func _ready() -> void:
	current_rope_length = rope_length
	
func gravity():
	velocity.y += grav
	
func move(delta):
	if Input.is_action_pressed("walk_left"):
		velocity.x -= speed
	if Input.is_action_pressed("walk_right"):
		velocity.x += speed
	else:
		velocity.x = 0
	
func _physics_process(delta: float) -> void:
	gravity()
	hook()
	queue_redraw()
	if hooked:
		gravity()
		swing(delta)
		velocity *= 0.975
	move(delta)
	move_and_slide()
	
func hook():
	$RayCast.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("grapple"):
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			current_rope_length = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("grapple"):
		hooked = false

func get_hook_pos():
	for raycast in $RayCast.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()
			

func swing(delta):
	var radius = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 10: return
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_vel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_vel
	
	if global_position.distance_to(hook_pos) > current_rope_length:
		global_position = hook_pos + radius.normalized() * current_rope_length
	
	velocity += (hook_pos - global_position).normalized() * 15000 * delta

func _draw() -> void:
	var pos = global_position
	
	if hooked:
		draw_line(Vector2(0, -32), to_local(hook_pos), Color.BLACK, 3, true)
	else:
		return
	
	if get_hook_pos() and pos.distance_to(get_hook_pos()) < rope_length:
		draw_line(Vector2(0, -32), to_local(hook_pos), Color(1, 1, 1, 0), 0.5, true)
