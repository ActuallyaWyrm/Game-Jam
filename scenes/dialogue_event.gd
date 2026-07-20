extends Area2D

@export var resource = load("res://test.dialogue")
@export var cue = "start"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		DialogueManager.show_dialogue_balloon(resource, cue)
