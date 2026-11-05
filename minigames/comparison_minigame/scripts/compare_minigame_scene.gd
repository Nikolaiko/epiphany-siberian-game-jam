extends Control

class_name CompareMinigame

var textMenu: TextMenuScene

func _ready() -> void:
	textMenu = load("res://scenes/common/text_menu/text_menu_scene.tscn").instantiate()
	textMenu.menuText = "Я в музее"
	textMenu.onCloseCallback = onInitialTextClosed 
	add_child(textMenu)

func onInitialTextClosed():
	remove_child(textMenu)
