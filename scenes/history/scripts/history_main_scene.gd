class_name StoryScene
extends Control

const CAFE_BACKGROUND: Texture2D = preload("res://assets/art/style-test/bg_cafe_evening.png")
const MYTH_BACKGROUND: Texture2D = preload("res://assets/art/style-test/bg_student_myth.png")

const DIALOGUE_PAGES: Array[String] = [
	"Я сидел вечером в любимой кофейне и пил любимый латте на кокосовом.",
	"На завтра мне нужно приготовить доклад по истории. Про Ледовое побоище. Что может быть проще?",
	(
		"Любому здравомыслящему человеку известно: мы победили в этой битве, "
		+ "потому что были едины, а тупые немцы полезли в тяжёлых доспехах на лёд."
	),
	(
		"Можно не заморачиваться: завтра с утра быстро пробегусь по музеям, "
		+ "понаделаю фоток, натыкаю ссылок на документы — и готово..."
	),
]

var finished_callback: Callable
var _page_index: int = 0

@onready var _dialogue_text: Label = %DialogueText
@onready var _page_counter: Label = %PageCounter
@onready var _next_button: Button = %NextButton
@onready var _background: TextureRect = $BackgroundContainer/TextureRect


func _ready() -> void:
	_show_page()
	_next_button.grab_focus()


func _show_page() -> void:
	_background.texture = CAFE_BACKGROUND if _page_index == 0 else MYTH_BACKGROUND
	_dialogue_text.text = DIALOGUE_PAGES[_page_index]
	_page_counter.text = "%d / %d" % [_page_index + 1, DIALOGUE_PAGES.size()]
	_next_button.text = "Начнём!" if _page_index == DIALOGUE_PAGES.size() - 1 else "Далее"


func _on_start_button_pressed() -> void:
	if _page_index < DIALOGUE_PAGES.size() - 1:
		_page_index += 1
		_show_page()
	elif finished_callback.is_valid():
		_next_button.disabled = true
		finished_callback.call()
