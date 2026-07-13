extends CharacterBody2D

# movement vars

var slide_mod = 1.5
var sliding = false
var speed = 25
var jump_height = 1500
var rope_length = 500
var rope_pull = 300
var grav = 100
var direction:
	set(value):
		if direction != value and (direction != 0):
			direction = 0
		else:
			direction = value
		
var hook_velocity = Vector2()
var angle = 0
var walk_angle = 0

# grapple vars

var hook_pos = Vector2()
var current_rope_length
var launched = false
var hooked = false
var zipping = false

# camera var

@onready var camera = $Camera2D

# create current rope var

func _ready() -> void:
	current_rope_length = rope_length
	
# have physics affect the player
	
func gravity():
	if hooked:
		velocity.y += grav * 3
	velocity.y += grav
	
# basic movement code (run + jump + slide)	
	
func move(delta):
	# set slope angle speed modifier
	
	var max_mod
	
	if (walk_angle == 180) or (walk_angle == 0):
		max_mod = 0
	else:
		max_mod = 1000 + abs(walk_angle)
	
	# jump
	
	if (Input.is_action_just_pressed("jump") and !zipping and !hooked and is_on_floor()):
		velocity.y -= (jump_height + max_mod)
	
	# climb up rope
	#if (Input.is_action_pressed("jump") and hooked):
		#velocity.y -= 150
	
	# walk
	
	if !zipping:
		direction = Input.get_axis("walk_left", "walk_right")
	else:
		direction = 0
	
	# slide
	
	if Input.is_action_just_pressed("slide"):
		sliding = true
		scale = lerp(scale, Vector2(1,0.25), 0.5)
	if Input.is_action_just_released("slide"):
		sliding = false
		scale = lerp(scale, Vector2(1,1.5), 0.5)
	
	# limit velocity
	
	if !sliding or !is_on_floor():
		if is_on_floor():
			walk_angle = rad_to_deg(get_floor_angle())
		else:
			walk_angle = 0
		velocity.x *= (1 + walk_angle) * 1.1
		velocity.x = clamp(lerp(velocity.x, velocity.x + speed * direction, 0.75), -2500 - max_mod / 2, 2500 + max_mod / 2)
		velocity.y *= 1 + (walk_angle / 100)
		velocity.y = clamp(velocity.y, -jump_height - max_mod, jump_height + max_mod)
		camera.global_rotation = 0
	else:
		if is_on_floor():
			walk_angle = rad_to_deg(get_floor_angle())
		else:
			walk_angle = 0
		velocity.x *= 1 + walk_angle * 1.2
		velocity.x = clamp(lerp(velocity.x, velocity.x + speed * slide_mod * direction, 0.85), -3000 - max_mod * 2, 3000 + max_mod * 2)
		velocity.y *= 1 + (walk_angle / 100)
		velocity.y = clamp(velocity.y, -jump_height - max_mod, jump_height + max_mod)
		camera.global_rotation = -0.3 * direction
	
	
	if !direction and !sliding:
		velocity.x *= 0
	elif !direction and sliding:
		velocity.x *= 0.05
	
# overall order of events
	
func _physics_process(delta: float) -> void:
	gravity()
	hook()
	queue_redraw()
	if hooked:
		gravity()
		swing(delta)
	elif zipping:
		zip(delta)
	move(delta)
	apply_floor_snap()
	move_and_slide()

# handle grapple input
	
func hook():
	$RayCast.look_at($Cursor.global_position)
	if Input.is_action_just_pressed("grapple"):
		hook_pos = get_hook_pos()
		if hook_pos and !zipping and !hooked:
			hooked = true
			hook_velocity = to_local(hook_pos).normalized() * rope_pull
			current_rope_length = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("grapple"):
		var release_mod = 1
		if hook_pos:
			if hook_pos.y < global_position.y:
				release_mod = -1
			else:
				release_mod = 1
		hooked = false
		hook_pos = false
		velocity.x *= (release_mod * direction)
	#if Input.is_action_just_pressed("zip"):
		#hook_pos = get_hook_pos()
		#if hook_pos and !zipping and !hooked:
			#zipping = true
			#current_rope_length = global_position.distance_to(hook_pos)
	#if Input.is_action_just_released("zip"):
		#hook_pos = false
		#zipping = false

# find where hook hit

func get_hook_pos():
	for raycast in $RayCast.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()
			

# swing player

func zip(delta):
	if hook_pos:
		var radius = global_position - hook_pos
		if velocity.length() < 0.01 or radius.length() < 10: return
		var angle = acos(clamp(radius.dot(velocity) / (radius.length() * velocity.length()), 0, 1))
		var rad_vel = cos(angle) * velocity.length()
		velocity += radius.normalized() * -rad_vel
		if global_position.distance_to(hook_pos) > current_rope_length:
			global_position = hook_pos + radius.normalized() * current_rope_length
		
		velocity += hook_velocity * (hook_pos - global_position).normalized() * 60000 * delta

func swing(delta):
	if hook_pos:
		var radius = global_position - hook_pos
		if velocity.length() < 0.01 or radius.length() < 10: return
		var angle = acos(clamp(radius.dot(velocity) / (radius.length() * velocity.length()), 0, 1))
		var rad_vel = cos(angle) * velocity.length()
		velocity.y -= rad_vel
		if global_position.distance_to(hook_pos) > current_rope_length:
			global_position = hook_pos + radius.normalized() * current_rope_length
		velocity += hook_velocity * direction * sqrt(current_rope_length) * 2 * delta

# simulate mouse cursor

func _input(event: InputEvent) -> void:
	var radius = 250
	if event is InputEventMouseMotion:
		$Cursor.global_position += event.screen_relative
		var normal = ($Cursor.global_position - global_position).normalized()
		$Cursor.global_position = global_position + (normal * radius)

# flip character to face appropriate direction
# draw line between hook and player

func _draw() -> void:
	if direction > 0:
		$AnimatedSprite2D.scale.x = 0.154
	if direction < 0:
		$AnimatedSprite2D.scale.x = -0.154
	
	var pos = global_position
	if hook_pos:
		if hooked or zipping:
			draw_line(Vector2(0, -32), to_local(hook_pos), Color.BLACK, 3, true)
	else:
		return
