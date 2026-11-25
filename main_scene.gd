class_name MainScene
extends Node

const TITLE_SCENE: PackedScene = preload("res://ui/title_scene/title_scene.tscn")
const STORY_SCENE: PackedScene = preload("res://locations/history/initial_story.tscn")
const CITY_SCENE: PackedScene = preload("res://locations/walkable_city/City.tscn")

var history_scene: StoryScene
var _notebook_available: bool = false
@onready var _notebook: Control = $NotebookLayer/NotebookMenu

func _ready() -> void:
	SceneRouter.setup($SceneContainer)
	SceneRouter.scene_opened.connect(_on_scene_opened)

	var title_scene: TitleScene = TITLE_SCENE.instantiate() as TitleScene
	title_scene.start_game_pressed.connect(_on_start_game_pressed)
	title_scene.exit_game_pressed.connect(_on_exit_game_pressed)
	SceneRouter.fast_go_to(title_scene)


func _on_start_game_pressed() -> void:
	GameData.reset_data()

	history_scene = STORY_SCENE.instantiate()
	history_scene.story_finished.connect(_on_history_scene_closed)
	SceneRouter.go_to(history_scene)


func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_scene_opened(scene: Node) -> void:
	_notebook_available = scene.scene_file_path == CITY_SCENE.resource_path

func _on_history_scene_closed() -> void:
	var city_scene: Node = CITY_SCENE.instantiate()
	SceneRouter.go_to(city_scene)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_notebook", false, true):
		if _toggle_notebook():
			get_viewport().set_input_as_handled()

func _toggle_notebook() -> bool:
	if not _notebook.visible and (not _notebook_available or get_tree().paused):
		return false

	_notebook.visible = not _notebook.visible
	get_tree().paused = _notebook.visible
	return true