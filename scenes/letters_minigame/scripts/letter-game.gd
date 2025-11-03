extends Control

class_name LetterGame

@onready var lettersRegion: LettersRegion = $ParentContainer/MarginContainer/LettersRegion

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func startLetterGame(words: Array[String]):
	lettersRegion.initGamePole(words)


func _on_letters_region_ready() -> void:
	get_node("ParentContainer/MarginContainer/LettersRegion").startGame()
