extends Node

class_name LetterCell

@export var row: int = 0
@export var column: int = 0
@export var letterParent: LetterParent

@onready var letterElement: Button = $LetterButton

var letter: String

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func setLetter(newLetter: String):
	letter = newLetter
	letterElement.text = letter
	
func getLetter() -> String:
	return letter

func _on_letter_button_button_down() -> void:
	letterParent.onLetterPressed(row, column)


func _on_letter_button_mouse_entered() -> void:
	letterParent.onLetterHoverOn(row, column)


func _on_letter_button_mouse_exited() -> void:
	letterParent.onLetterHoverOut(row, column)

func _on_letter_button_button_up() -> void:
	letterParent.onLetterReleased()
