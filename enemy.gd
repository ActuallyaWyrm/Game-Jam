extends CharacterBody2D

@export var cooldown:Dictionary = {"current":0, "reset":120}

@export var enhealth:float

@export var damage:float

@export var SPEED = 150.0

var inrange:Array[CharacterBody2D]

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	var direction = (player.global_position-global_position).normalized()

	velocity=SPEED*direction

	if cooldown["current"] > 0:
		cooldown["current"]-=1
	elif inrange.size()>0:
		inrange[0].health-=damage
		cooldown["current"] = cooldown["reset"]
		print_debug(inrange[0].health)
		inrange[0].checkifdead()

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	inrange.append(body)
	cooldown["current"] = cooldown["reset"]


func _on_area_2d_body_exited(body: Node2D) -> void:
	inrange.erase(body)

func checkifdead():
	if enhealth <= 0:
		queue_free()
