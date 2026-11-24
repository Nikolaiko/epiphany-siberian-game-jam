class_name  CardsRow
extends HBoxContainer

signal flip_requested(card: CardData)

var _card: CardData


func disply_card(card: CardData, side: GameState.CardSide) -> void:
    _card = card
    $Title.text = String(_card.id)
    $Side.text = "Myth" if side == GameState.CardSide.MYTH else "Fact"

func _on_card_flip_requested() -> void:
    flip_requested.emit(_card)