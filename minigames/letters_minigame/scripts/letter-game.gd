class_name LetterGame
extends Control

@onready var letters_region: LettersRegion = $ParentContainer/MarginContainer/LettersRegion


func start_letter_game(words: Array[String]):
	letters_region.init_game_pole(words)


func _on_letters_region_ready() -> void:
	get_node("ParentContainer/MarginContainer/LettersRegion").start_game()
