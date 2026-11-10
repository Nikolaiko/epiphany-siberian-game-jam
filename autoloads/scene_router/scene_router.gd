extends Node

signal scene_opened(scene: Node)

const FADE_DURATION: float = 0.35

var _container: Node
var _current_scene: Node
var _transitioning := false

@onready var _fade_rect: ColorRect = $CanvasLayer/FadeRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.hide()


func setup(container: Node) -> void:
	_container = container


func fast_go_to(scene: Node) -> void:
	if _transitioning:
		return

	if not is_instance_valid(_container) or scene == null:
		push_error("SceneRouter: не задан контейнер или сцена.")
		return

	if is_instance_valid(_current_scene):
		_container.remove_child(_current_scene)
		_current_scene.queue_free()

	_current_scene = scene
	_container.add_child(_current_scene)
	scene_opened.emit(_current_scene)


func go_to(scene: Node) -> void:
	if _transitioning:
		return

	if not is_instance_valid(_container) or scene == null:
		push_error("SceneRouter: не задан контейнер или сцена.")
		return

	_transitioning = true

	var was_paused := get_tree().paused
	get_tree().paused = true

	_fade_rect.show()
	await _fade_to(1.0)

	if is_instance_valid(_current_scene):
		_container.remove_child(_current_scene)
		_current_scene.queue_free()

	_current_scene = scene
	_container.add_child(_current_scene)
	scene_opened.emit(_current_scene)

	await _fade_to(0.0)
	_fade_rect.hide()

	get_tree().paused = was_paused
	_transitioning = false


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", alpha, FADE_DURATION)
	await tween.finished
