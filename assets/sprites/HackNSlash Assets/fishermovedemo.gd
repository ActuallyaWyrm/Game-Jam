extends CharacterBody2D

@export var health: float = 100
@export var damage: float = 5
@export var speed: float = 300.0
@export var cooldown: Dictionary[String,int] = {"current":0,"reset":60}
@export var sprite: AnimatedSprite2D
var direction
var facing = 1
var in_range: Array[CharacterBody2D]

func _physics_process(delta: float) -> void:

	# Movement
	direction = Input.get_vector("walk_left","walk_right","walk_up","walk_down")
	facing = Input.get_axis("walk_left", "walk_right")
	velocity = speed * direction
	move_and_slide()
	
	# Reduce cooldown
	if cooldown["current"] > 0:
		cooldown["current"] -= 1
	else:
		# Attack!
		if Input.is_action_just_pressed("grapple"):
			sprite.play("attack")
			for i in in_range:
				i.enhealth -= damage
				cooldown["current"] = cooldown["reset"]
				i.checkifdead()
		else:
			sprite.play("static")
		_draw()

# Add / remove enemy from range
func _on_attack_area_entered(body: Node2D) -> void:
	in_range.append(body)

func _on_attack_area_exited(body: Node2D) -> void:
	in_range.erase(body)

# Die
func checkifdead():
	if health <= 0:
		get_tree().reload_current_scene()
		
func _draw() -> void:
	if facing == -1:
		$AnimatedSprite2D.scale.x = -1
	if facing == 1:
		$AnimatedSprite2D.scale.x = 1
		
