class_name MainScene
extends Node

const TITLE_SCENE: PackedScene = preload("res://ui/initial_screen/initial_screen.tscn")
const STORY_SCENE: PackedScene = preload("res://locations/history/initial_story.tscn")

var history_scene: StoryScene

@onready var main_canvas: CanvasLayer = $CanvasLayer

func _ready() -> void:
	SceneRouter.setup($Container)

	var title_scene: Node = TITLE_SCENE.instantiate()
	title_scene.start_game_pressed.connect(_on_start_game_pressed)
	title_scene.exit_game_pressed.connect(_on_exit_game_pressed)
	SceneRouter.fast_go_to(title_scene)

func _on_start_game_pressed() -> void:
	var history_scene: Node = STORY_SCENE.instantiate()
	SceneRouter.go_to(history_scene)

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_history_scene_closed():
	if history_scene != null:
		main_canvas.remove_child(history_scene)
		history_scene.queue_free()
		history_scene = null

	var city_scene = load("res://locations/walkable_city/City.tscn").instantiate()
	add_child(city_scene)


func _on_start_letters_game_button_pressed() -> void:
	var letter_game: LetterGame = (
		load("res://minigames/letters_minigame/letter_mini_game.tscn").instantiate()
	)
	main_canvas.add_child(letter_game)
