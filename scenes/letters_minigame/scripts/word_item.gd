extends Control

class_name WordItem

func setWord(newWord: String):
	get_node("TextEdit").text = newWord
	
func getWord() -> String:
	return get_node("TextEdit").text
