class_name CompareMinigame
extends Control

var text_menu: TextMenu


func _ready() -> void:
	text_menu = load("res://ui/text_menu/text_menu_scene.tscn").instantiate()
	text_menu.menu_text = "Я в музее"
	text_menu.close.connect(on_initial_text_closed)
	add_child(text_menu)


func on_initial_text_closed():
	remove_child(text_menu)
