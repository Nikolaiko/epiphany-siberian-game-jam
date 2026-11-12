extends Node

signal scene_opened(scene: Node)

const FADE_DURATION: float = 0.35

var _contianer: Node
var _current_scene: Node
var _transitioning: bool = false

@onready var _fade_rect: ColorRect = %FadeRect

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _fade_rect.color = Color(0, 0, 0, 0)
    _fade_rect.hide()

func setup(container: Node) -> void:
    _contianer = container

func go_to(scene: Node) -> void:
    if _transitioning:
        return
    
    if not is_instance_valid(_contianer) or scene == null:
        push_error("SceneRouter: Invalid container or scene.")
        return

    _transitioning = true

    var was_paused: bool = get_tree().paused
    get_tree().paused = true

    _fade_rect.show()
    await fade_to(1.0)

    if is_instance_valid(_current_scene):
        _contianer.remove_child(_current_scene)
        _current_scene.queue_free()

    _current_scene = scene
    _contianer.add_child(_current_scene)
    scene_opened.emit(_current_scene)

    await fade_to(0.0)
    _fade_rect.hide()
    get_tree().paused = was_paused
    _transitioning = false

func fast_go_to(scene: Node) -> void:
    if _transitioning:
        return
    
    if not is_instance_valid(_contianer) or scene == null:
        push_error("SceneRouter: Invalid container or scene.")
        return

    if is_instance_valid(_current_scene):
        _contianer.remove_child(_current_scene)
        _current_scene.queue_free()

    _current_scene = scene
    _contianer.add_child(_current_scene)
    scene_opened.emit(_current_scene)    

func fade_to(alpha: float) -> void:    
    var tween: Tween = create_tween()
    tween.tween_property(_fade_rect, "color:a", alpha, FADE_DURATION)
    await tween.finished