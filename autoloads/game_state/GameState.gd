extends Node

signal card_give(card: CardData)
signal card_flipped(card: CardData)

signal location_visited(location: Location)
signal location_reset(location: Location)

signal finding_founded(finding: FindingsData)

signal reset_data

enum CardSide { MYTH, FACT }
enum Location { MUSEUM, ARCHIVE, CINEMA, SQUARE }

var cards: Dictionary[CardData, CardSide] = {}
var founded_findings: Array[FindingsData] = []
var completed_locations: Array[Location] = []

func give_card(card: CardData) -> void:
    if cards.has(card):
        return

    cards[card] = CardSide.MYTH
    card_give.emit(card)

func flip_card(card: CardData) -> void:
    if not cards.has(card):
        return

    if cards[card] == CardSide.MYTH:
        cards[card] = CardSide.FACT
    else:
        cards[card] = CardSide.MYTH
    
    card_flipped.emit(card)

func visit_location(location: Location) -> void:
    if completed_locations.has(location):
        return

    completed_locations.append(location)
    location_visited.emit(location)

func reset_location(location: Location) -> void:
    if not completed_locations.has(location):
        return

    completed_locations.erase(location)
    location_reset.emit(location)

func finding_was_founded(finding: FindingsData) -> void:
    if founded_findings.has(finding):
        return

    founded_findings.append(finding)
    finding_founded.emit(finding)

func reset_saved_data() -> void:
    cards.clear()
    founded_findings.clear()
    completed_locations.clear()

    reset_data.emit()