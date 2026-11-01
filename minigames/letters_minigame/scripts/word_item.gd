class_name WordItem
extends Control


func set_word(new_word: String):
	get_node("TextEdit").text = new_word


func get_word() -> String:
	return get_node("TextEdit").text
