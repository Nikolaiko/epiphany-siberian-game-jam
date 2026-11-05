class_name TextMenuScene
extends Control

var menu_text: String
var on_close_callback: Callable

@onready var label: Label = $MarginContainer/VBoxContainer/Label


func _ready() -> void:
	label.text = menu_text


func _on_close_button_pressed() -> void:
	if on_close_callback != null:
		on_close_callback.call()
