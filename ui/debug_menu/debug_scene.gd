extends CanvasLayer

const CARD_ROW := preload("res://ui/debug_menu/cards_row/cards_row.tscn")

var _rows: Dictionary[CardData, CardsRow] = {}


@onready var _cards_list: VBoxContainer = %CardsList

func _ready() -> void:
    hide()
    set_process_input(OS.has_feature("editor_runtime"))

    GameState.card_give.connect(_update_card)
    GameState.card_flipped.connect(_update_card)

    %CloseButton.pressed.connect(self.hide)

func _update_card(card: CardData) -> void:
    if not _rows.has(card):
        var row: CardsRow = CARD_ROW.instantiate() as CardsRow
        _cards_list.add_child(row)

        row.flip_requested.connect(GameState.flip_card)
        _rows[card] = row

    _rows[card].disply_card(card, GameState.cards[card])

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_F1:
        if event.is_pressed() and not event.is_echo():
            visible = not visible
            get_viewport().set_input_as_handled()
