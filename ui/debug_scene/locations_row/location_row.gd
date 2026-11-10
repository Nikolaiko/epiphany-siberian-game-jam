class_name LocationRow
extends HBoxContainer

signal reset_requested(location: GameData.Location)

var _location: GameData.Location


func display(location: GameData.Location) -> void:
	_location = location
	$Title.text = String(GameData.Location.find_key(_location))


func set_button_title(title: String) -> void:
	$FlipButton.text = title


func _on_reset_button_pressed() -> void:
	reset_requested.emit(_location)
