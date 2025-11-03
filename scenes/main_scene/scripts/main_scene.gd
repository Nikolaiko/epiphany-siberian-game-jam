extends Node

class_name MainScene

@onready var mainCanvas = $CanvasLayer

func _ready() -> void:
	var letterGame = load("res://scenes/letters_minigame/letter_mini_game.tscn")
	mainCanvas.add_child(letterGame.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
