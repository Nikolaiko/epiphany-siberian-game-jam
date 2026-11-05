class_name TitleScene
extends Control

signal start_game_pressed()
signal exit_game_pressed()

@onready var _start_button: Button = %StartButton
@onready var _exit_button: Button = %ExitButton

func _ready() -> void:
    _start_button.on_pressed.connect(_on_start_button_pressed)
    _exit_button.on_pressed.connect(_on_exit_button_pressed)
    _start_button.grab_focus()

func _on_start_button_pressed() -> void:
    emit_signal("start_game_pressed")

func _on_exit_button_pressed() -> void:
    emit_signal("exit_game_pressed")


