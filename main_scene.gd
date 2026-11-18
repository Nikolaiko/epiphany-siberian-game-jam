class_name MainScene
extends Node

const TITLE_SCENE: PackedScene = preload("res://ui/initial_screen/initial_screen.tscn")
const STORY_SCENE: PackedScene = preload("res://locations/history/initial_story.tscn")
const TOWN_SCENE: PackedScene = preload("res://locations/walkable_city/City.tscn")

func _ready() -> void:
	SceneRouter.setup($Container)

	var title_scene: Node = TITLE_SCENE.instantiate()
	title_scene.start_game_pressed.connect(_on_start_game_pressed)
	title_scene.exit_game_pressed.connect(_on_exit_game_pressed)
	SceneRouter.fast_go_to(title_scene)

func _on_start_game_pressed() -> void:
	var history_scene: StoryScene = STORY_SCENE.instantiate()
	history_scene.story_finished.connect(_on_history_scene_closed)
	SceneRouter.go_to(history_scene)

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_history_scene_closed() -> void:
	var town_scene: Node = TOWN_SCENE.instantiate()
	SceneRouter.go_to(town_scene)

func _on_start_letters_game_button_pressed() -> void:
	pass
