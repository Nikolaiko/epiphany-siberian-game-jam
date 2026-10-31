class_name MainScene
extends Node

var history_scene: StoryScene

@onready var main_canvas = $CanvasLayer


func _ready() -> void:
	history_scene = load("res://scenes/history/initial_story.tscn").instantiate()
	history_scene.finished_callback = _on_history_scene_closed
	main_canvas.add_child(history_scene)


func _on_history_scene_closed():
	if history_scene != null:
		main_canvas.remove_child(history_scene)
		history_scene.queue_free()
		history_scene = null

	var city_scene = load("res://scenes/walkable_city/City.tscn").instantiate()
	add_child(city_scene)


func _on_start_letters_game_button_pressed() -> void:
	var letter_game: LetterGame = (
		load("res://scenes/letters_minigame/letter_mini_game.tscn").instantiate()
	)
	main_canvas.add_child(letter_game)
