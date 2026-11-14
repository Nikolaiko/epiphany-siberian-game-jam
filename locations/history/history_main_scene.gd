class_name StoryScene
extends Control

signal story_finished

const PROLOGUE: DialogueResource = preload("res://data/dialoges/prologue.dialogue")

const CARD_K1: CardData = preload("res://data/cards/k1.tres")
const CARD_K2: CardData = preload("res://data/cards/k2.tres")
const CARD_K3: CardData = preload("res://data/cards/k3.tres")
const CARD_K4: CardData = preload("res://data/cards/k4.tres")
const CARD_K5: CardData = preload("res://data/cards/k5.tres")

const CAFE_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_evening.png")
const MYTH_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_student_myth.png")
const NOTES_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_notebook.png")
const GLEB_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_gleb.png")
const GLEB_DIALOGUE_BACKGROUND: Texture2D = preload(
	"res://assets/art/backgrounds/bg_cafe_gleb_dialogue.png"
)

const GLEB_CALM_AVATAR: Texture2D = preload("res://assets/art/portraits/portrait_gleb_calm.png")
const GLEB_SMIRK_AVATAR: Texture2D = preload("res://assets/art/portraits/portrait_gleb_smirk.png")
const STUDENT_CALM_AVATAR: Texture2D = preload(
	"res://assets/art/portraits/portrait_student_calm.png"
)

var _current_line: DialogueLine
var _busy: bool = false

@onready var _dialogue_text: DialogueLabel = %DialogueText
@onready var _next_button: Button = %NextButton
@onready var _background: TextureRect = $BackgroundContainer/TextureRect
@onready var _avatar: TextureRect = %Portrait
@onready var _avatar_title: Label = %Speaker


func _ready() -> void:
	await _show_line("start")


func _show_line(line_id: String) -> void:
	_busy = true
	_next_button.disabled = true

	_current_line = await PROLOGUE.get_next_dialogue_line(line_id)
	if _current_line == null:
		story_finished.emit()
		return

	_dialogue_text.dialogue_line = _current_line
	_avatar_title.text = _current_line.character
	_avatar_title.visible = true

	_apply_background()
	_apply_portrait()
	_dialogue_text.type_out()

	if _current_line.has_tag("cards"):
		_give_cards()

	_next_button.text = ("Начнем!" if _current_line.has_tag("last") else "Продолжить")
	_next_button.disabled = false
	_busy = false
	_next_button.grab_focus()


func _give_cards() -> void:
	GameData.give_card(CARD_K1)
	GameData.give_card(CARD_K2)
	GameData.give_card(CARD_K3)
	GameData.give_card(CARD_K4)
	GameData.give_card(CARD_K5)


func _apply_background() -> void:
	match _current_line.get_tag_value("bg"):
		"cafe":
			_background.texture = CAFE_BACKGROUND
		"myth":
			_background.texture = MYTH_BACKGROUND
		"notes":
			_background.texture = NOTES_BACKGROUND
		"gleb":
			_background.texture = GLEB_BACKGROUND
		"talk":
			_background.texture = GLEB_DIALOGUE_BACKGROUND


func _apply_portrait() -> void:
	_avatar.visible = true

	match _current_line.character:
		"Студент":
			_avatar.texture = STUDENT_CALM_AVATAR
		"Глеб":
			_avatar.texture = (
				GLEB_CALM_AVATAR
				if _current_line.get_tag_value("portrait") == "calm"
				else GLEB_SMIRK_AVATAR
			)
		_:
			_avatar.texture = null
			_avatar.hide()


func _on_start_button_pressed() -> void:
	if _busy or _current_line == null:
		return

	if _dialogue_text.is_typing:
		_dialogue_text.skip_typing()
		return

	await _show_line(_current_line.next_id)


func _on_dialogue_text_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_dialogue_text.accept_event()
		_on_start_button_pressed()
