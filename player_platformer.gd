extends CharacterBody2D

# movement vars

var slide_mod = 1.5
var sliding = false
var speed = 2000
var jump_height = 1500
var rope_length = 400
var rope_pull = 300
var grav = 100
var jumping = false
var direction:
	set(value):
		if direction != value and (direction != 0):
			direction = 0
		else:
			direction = value
		
var hook_velocity = Vector2()
var angle = 0
var walk_angle = 0
var release_mod = 0
var vertical_boost = 0

# grapple vars

var hook_pos = Vector2()
var current_rope_length
var launched = false
var hooked = false
var zipping = false

# drawing vars

var draw_slide = false
var draw_jump = false
var draw_swing_air = false
@onready var animation = $AnimatedSprite2D
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
	
	jumping = Input.is_action_just_pressed("jump") and !zipping and !hooked and is_on_floor()
	
	if jumping:
		velocity.y -= (jump_height + max_mod)
		draw_jump = true


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
		draw_slide = true
	if Input.is_action_just_released("slide"):
		sliding = false
		draw_slide = false
	
	# limit velocity
	
	if !sliding or !is_on_floor():
		if is_on_floor():
			walk_angle = rad_to_deg(get_floor_angle())
		else:
			walk_angle = 0
		velocity.y *= vertical_boost
		vertical_boost = 1
		velocity.x = clamp(lerp(velocity.x, float(speed * direction), 0.75), -2500 - max_mod, 2500 + max_mod)
		velocity.y = clamp(velocity.y, -jump_height - max_mod, jump_height + max_mod)
		camera.global_rotation = 0
	else:
		if is_on_floor():
			walk_angle = rad_to_deg(get_floor_angle())
		else:
			walk_angle = 0
		velocity.y *= vertical_boost
		vertical_boost = 1
		velocity.x = clamp(lerp(velocity.x, speed * slide_mod * direction, 0.85), -3000 - max_mod * 2, 3000 + max_mod * 2)
		velocity.y = clamp(velocity.y, -jump_height - max_mod * 2, jump_height + max_mod * 2)
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
	move_and_slide()

# handle grapple input
	
func hook():
	$RayCast.look_at($Cursor.global_position)
	if Input.is_action_just_pressed("grapple"):
		draw_swing_air = true
		hook_pos = get_hook_pos()
		if hook_pos and !zipping and !hooked:
			hooked = true
			hook_velocity = to_local(hook_pos).normalized() * rope_pull
			current_rope_length = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("grapple"):
		if hook_pos:
			if hook_pos.y > global_position.y:
				release_mod = -1
				vertical_boost = 2500
			else:
				release_mod = 1
				vertical_boost = 1
		hooked = false
		hook_pos = false
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
	if hook_pos:
		if hooked or zipping:
			draw_line(Vector2(0, -32), to_local(hook_pos), Color.BLACK, 3, true)
	if draw_swing_air:
		animation.play("swing_air")
		animation.speed_scale = 4
		await animation.animation_finished
		draw_swing_air = false
	elif is_on_floor():
		if !sliding:
			if direction != 0:
				animation.play("walk")
				animation.speed_scale = velocity.x / 1000
			else:
				animation.play("idle")
				animation.speed_scale = 0.5
		elif draw_slide:
			animation.play("slide_enter")
			animation.speed_scale = 2
			await animation.animation_finished
			draw_slide = false
		else:
			animation.play("slide")
			animation.speed_scale = 2 * abs(direction)
			
	elif draw_jump:
		animation.play("jump")
		animation.speed_scale = 2
		await animation.animation_finished
		draw_jump = false
	else:
		animation.play("fall")
		animation.speed_scale = 1
	if direction > 0:
		animation.scale.x = 5
	if direction < 0:
		animation.scale.x = -5
	var pos = global_position
