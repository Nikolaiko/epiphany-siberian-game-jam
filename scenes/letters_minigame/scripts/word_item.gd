extends Control

class_name WordItem

@onready var textField: TextEdit = $TextEdit

func _ready() -> void:
	print("Word reqdy")

func setWord(newWord: String):
	textField.text = newWord
	
func getWord() -> String:
	return textField.text
