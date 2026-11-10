extends CanvasLayer

const CARD_ROW := preload("res://ui/debug_scene/card_row/card_row.tscn")
const LOCATION_ROW := preload("res://ui/debug_scene/locations_row/locations_row.tscn")
const FINDING_ROW := preload("res://ui/debug_scene/finding_row/finding_row.tscn")

var _rows: Dictionary[CardData, CardRow] = {}
var _locations_rows: Dictionary[GameData.Location, LocationRow] = {}
var _findings_rows: Dictionary[FoundingData, FindingRow] = {}

var _visited_locations: Array[GameData.Location] = []

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

	GameData.reset_saved_data.connect(_reset_all_data)

	%CloseButton.pressed.connect(self.hide)

	_init_locations()


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


func _init_locations() -> void:
	for location in GameData.Location.values():
		_init_location(location)


func _init_location(location: GameData.Location) -> void:
	if _locations_rows.has(location):
		return

	var row = LOCATION_ROW.instantiate() as LocationRow
	row.display(location)
	row.set_button_title("Посетить")
	row.reset_requested.connect(_flip_location)
	_locations_list.add_child(row)
	_locations_rows[location] = row


func _flip_location(location: GameData.Location) -> void:
	if not _visited_locations.has(location):
		GameData.visit_location(location)
	else:
		GameData.reset_location(location)


func _add_location(location: GameData.Location) -> void:
	_visited_locations.append(location)

	var row = _locations_rows[location]
	row.set_button_title("Сбросить")


func _remove_location(location: GameData.Location) -> void:
	_visited_locations.remove_at(_visited_locations.find(location))

	var row = _locations_rows[location]
	row.set_button_title("Посетить")


func _add_finding(finding: FoundingData) -> void:
	if _findings_rows.has(finding):
		return

	var row = FINDING_ROW.instantiate() as FindingRow
	row.display(finding)
	_findings_list.add_child(row)

	_findings_rows[finding] = row


func _reset_all_data() -> void:
	for row in _rows.values():
		row.queue_free()
	_rows.clear()

	for row in _locations_rows.values():
		row.queue_free()
	_locations_rows.clear()

	for row in _findings_rows.values():
		row.queue_free()
	_findings_rows.clear()

	_visited_locations.clear()

	_init_locations()
