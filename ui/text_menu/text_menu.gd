class_name TextMenu
extends Control

var menu_text: String

@onready var label: Label = $MarginContainer/VBoxContainer/Label

signal close()

func _ready() -> void:
	label.text = menu_text


func _on_close_button_pressed() -> void:
	close.emit()
