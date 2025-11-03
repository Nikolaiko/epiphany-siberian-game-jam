extends Control

class_name StoryScene

var callbackFunction: Callable

func _on_start_button_pressed() -> void:
	if (callbackFunction != null):
		callbackFunction.call()
