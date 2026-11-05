extends Control

class_name TextMenuScene

@onready var label: Label = $MarginContainer/VBoxContainer/Label

var menuText: String
var onCloseCallback: Callable

func _ready() -> void:
	label.text = menuText
	

func _on_close_button_pressed() -> void:
	if (onCloseCallback != null):
		onCloseCallback.call()
