class_name TitleScene
extends Control

signal start_game_pressed
signal exit_game_pressed

@onready var _start_button: TextureButton = %StartButton
@onready var _exit_button: TextureButton = %ExitButton


func _ready() -> void:
	_start_button.pressed.connect(_on_start_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)
	_start_button.grab_focus()

	if OS.has_feature("web"):
		_exit_button.visible = false


func _on_start_button_pressed() -> void:
	_start_button.disabled = true
	_exit_button.disabled = true

	emit_signal("start_game_pressed")


func _on_exit_button_pressed() -> void:
	_start_button.disabled = true
	_exit_button.disabled = true

	emit_signal("exit_game_pressed")
