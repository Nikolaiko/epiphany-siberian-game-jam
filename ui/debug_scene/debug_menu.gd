extends CanvasLayer

const CARD_ROW := preload("res://ui/debug_scene/card_row/card_row.tscn")
const LOCATION_ROW := preload("res://ui/debug_scene/locations_row/locations_row.tscn")
const FINDING_ROW := preload("res://ui/debug_scene/finding_row/finding_row.tscn")

var _rows: Dictionary[CardData, CardRow] = {}
var _locations_rows: Dictionary[GameData.Location, LocationRow] = {}
var _findings_rows: Dictionary[FoundingData, FindingRow] = {}

@onready var _card_list: VBoxContainer = %CardsList
@onready var _locations_list: VBoxContainer = %LocationsList
@onready var _findings_list: VBoxContainer = %FindingsList

func _ready() -> void:
    hide()
    set_process_input(OS.has_feature("editor_runtime"))
    GameData.card_given.connect(_update_card)
    GameData.card_flipped.connect(_update_card)

    GameData.location_visited.connect(_add_location)
    GameData.location_reset.connect(_remove_location)

    GameData.finding_founded.connect(_add_finding)

    %CloseButton.pressed.connect(self.hide)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_F1:
        if event.pressed and not event.echo:
            visible = not visible
            get_viewport().set_input_as_handled()

func _update_card(card: CardData) -> void:
    if not _rows.has(card):
        var row = CARD_ROW.instantiate() as CardRow
        _card_list.add_child(row)
        row.flip_requested.connect(GameData.flip_card)
        _rows[card] = row

    _rows[card].display(card, GameData.cards[card])

func _add_location(location: GameData.Location) -> void:
    if _locations_rows.has(location):
        return

    var row = LOCATION_ROW.instantiate() as LocationRow
    row.display(location)
    _locations_list.add_child(row)
    row.reset_requested.connect(GameData.reset_location)
    _locations_rows[location] = row
    
func _remove_location(location: GameData.Location) -> void:
    if not _locations_rows.has(location):
        return

    var row = _locations_rows[location]
    _locations_list.remove_child(row)
    row.queue_free()
    _locations_rows.erase(location)

func _add_finding(finding: FoundingData) -> void:
    if _findings_rows.has(finding):
        return

    var row = FINDING_ROW.instantiate() as FindingRow
    row.display(finding)
    _findings_list.add_child(row)

    _findings_rows[finding] = row
    
