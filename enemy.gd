extends CharacterBody2D

@export var sprite: AnimatedSprite2D

@export var enhealth:float

@export var damage:float

@export var SPEED = 150.0

var inrange:Array[CharacterBody2D]

var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	if enhealth > 0:
		var direction = (player.global_position-global_position).normalized()

		velocity=SPEED*direction

		if sprite.animation == "walk" and inrange.size()>0:
			velocity = Vector2(0,0)
			inrange[0].health-=damage
			sprite.play("attack")
			inrange[0].checkifdead()

		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	inrange.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	inrange.erase(body)

func checkifdead():
	sprite.play("gethit")
	await(0.75)
	if enhealth <= 0:
		sprite.play("die")

func _on_animation_finished() -> void:
	match sprite.animation:
		"attack":
			sprite.play("walk")
		"gethit":
			sprite.play("walk")
		"die":
			queue_free()
