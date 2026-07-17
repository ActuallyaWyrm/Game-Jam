extends CharacterBody2D

@export var health: float = 100
@export var damage: float = 5
@export var speed: float = 300.0
@export var cooldown: Dictionary[String,int] = {"current":0,"reset":120}
var in_range: Array[CharacterBody2D]

func _physics_process(delta: float) -> void:

	# Movement
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = speed * direction
	move_and_slide()
	
	# Reduce cooldown
	if cooldown["current"] > 0:
		cooldown["current"] -= 1
	else:
		# Attack!
		if Input.is_action_just_pressed("grapple"):
			for i in in_range:
				i.enhealth -= damage
				cooldown["current"] = cooldown["reset"]
				i.cooldown["current"] = i.cooldown["reset"]
				i.checkifdead()

# Add / remove enemy from range
func _on_attack_area_entered(body: Node2D) -> void:
	in_range.append(body)

func _on_attack_area_exited(body: Node2D) -> void:
	in_range.erase(body)

# Die
func checkifdead():
	if health <= 0:
		get_tree().reload_current_scene()
