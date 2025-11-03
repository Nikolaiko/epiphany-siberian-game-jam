extends Node

class_name MainScene

@onready var mainCanvas = $CanvasLayer

var historyScene: StoryScene

func _ready() -> void:
	historyScene = load("res://scenes/history/initial_story.tscn").instantiate()
	historyScene.callbackFunction = onHistorySceneClosed
	mainCanvas.add_child(historyScene)

func onHistorySceneClosed():
	if (historyScene != null):
		mainCanvas.remove_child(historyScene)	

func _on_start_letters_game_button_pressed() -> void:
	var letterGame: LetterGame = load("res://scenes/letters_minigame/letter_mini_game.tscn").instantiate()	
	mainCanvas.add_child(letterGame)
	
