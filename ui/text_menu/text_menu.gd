class_name TextMenu
extends Control

signal close

var menu_text: String

@onready var label: Label = $MarginContainer/VBoxContainer/Label


func _ready() -> void:
	label.text = menu_text


func _on_close_button_pressed() -> void:
	close.emit()
