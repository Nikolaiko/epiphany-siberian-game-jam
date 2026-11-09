class_name MainScene
extends Node

const TITLE_SCENE: PackedScene = preload(
	"res://ui/title_scene/title_scene.tscn"
)
const STORY_SCENE: PackedScene = preload(
	"res://locations/history/initial_story.tscn"
)
const CITY_SCENE: PackedScene = preload(
	"res://locations/walkable_city/City.tscn"
)

var history_scene: StoryScene

func _ready() -> void:
	SceneRouter.setup($SceneContainer)
	var title_scene = TITLE_SCENE.instantiate()
	title_scene.start_game_pressed.connect(_on_start_game_pressed)
	title_scene.exit_game_pressed.connect(_on_exit_game_pressed)
	SceneRouter.fast_go_to(title_scene)

func _on_start_game_pressed() -> void:
	GameData.reset()

	history_scene = STORY_SCENE.instantiate()
	history_scene.story_finished.connect(_on_history_scene_closed)
	SceneRouter.go_to(history_scene)

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_history_scene_closed():
	var city_scene = CITY_SCENE.instantiate()
	SceneRouter.go_to(city_scene)

