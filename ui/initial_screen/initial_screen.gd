class_name InitialScreen
extends Control

signal start_game_pressed
signal exit_game_pressed

@onready var _start_game_button = %StartButton
@onready var _exit_game_button = %ExitButton

func _ready() -> void:
    _start_game_button.pressed.connect(_on_start_button_pressed)
    _exit_game_button.pressed.connect(_on_exit_button_pressed)

    _start_game_button.grab_focus()
    if OS.has_feature("web"):
        _exit_game_button.hide()

func _on_start_button_pressed() -> void:
    _start_game_button.disabled = true
    _exit_game_button.disabled = true

    start_game_pressed.emit()

func _on_exit_button_pressed() -> void:
    _start_game_button.disabled = true
    _exit_game_button.disabled = true

    exit_game_pressed.emit()