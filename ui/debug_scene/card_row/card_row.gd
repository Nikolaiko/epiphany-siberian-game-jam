class_name CardRow
extends HBoxContainer

signal flip_requested(card: CardData)

var _card: CardData


func display(card: CardData, side: GameData.CardSide) -> void:
	_card = card
	$Title.text = String(card.id).to_upper()
	$Side.text = "Миф" if side == GameData.CardSide.MYTH else "Факт"


func _on_flip_button_pressed() -> void:
	flip_requested.emit(_card)
