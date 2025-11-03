extends Node

class_name MainScene

@onready var mainCanvas = $CanvasLayer

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_letters_game_button_pressed() -> void:
	var letterGame: LetterGame = load("res://scenes/letters_minigame/letter_mini_game.tscn").instantiate()	
	mainCanvas.add_child(letterGame)
	
