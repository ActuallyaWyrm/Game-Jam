extends CharacterBody2D

var health = 100

var inrange:Array[CharacterBody2D]

const SPEED = 300.0

func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	if Input.is_action_just_pressed("grapple"):
		print_debug(inrange)
		for I in inrange:
			I.enhealth -= 5
			I.checkifdead()
			print_debug(I.enhealth)
	
func checkifdead():
	if health <= 0:
		get_tree().reload_current_scene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	inrange.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	inrange.erase(body)
