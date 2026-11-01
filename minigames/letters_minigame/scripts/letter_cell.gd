class_name LetterCell
extends Node

@export var row: int = 0
@export var column: int = 0
@export var letter_parent: LetterParent

var letter: String

@onready var letter_element: Button = $LetterButton


func set_letter(new_letter: String):
	letter = new_letter
	letter_element.text = letter


func get_letter() -> String:
	return letter


func _on_letter_button_button_down() -> void:
	letter_parent.on_letter_pressed(row, column)


func _on_letter_button_mouse_entered() -> void:
	letter_parent.on_letter_hover_on(row, column)


func _on_letter_button_mouse_exited() -> void:
	letter_parent.on_letter_hover_out(row, column)


func _on_letter_button_button_up() -> void:
	letter_parent.on_letter_released()
