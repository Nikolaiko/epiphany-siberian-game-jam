class_name FindingRow
extends HBoxContainer

signal reset_requested(finding: FoundingData)

var _founding: FoundingData

func display(founding: FoundingData) -> void:
    _founding = founding
    $Title.text = String(_founding.text)

func _on_reset_button_pressed() -> void:
    reset_requested.emit(_founding)