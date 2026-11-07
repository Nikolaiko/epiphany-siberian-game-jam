class_name StoryScene
extends Control

const CAFE_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_evening.png")
const MYTH_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_student_myth.png")
const NOTES_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_notebook.png")
const GLEB_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_gleb.png")
const GLEB_DIALOGUE_BACKGROUND: Texture2D = preload("res://assets/art/backgrounds/bg_cafe_gleb_dialogue.png")

const GLEB_CALM_AVATAR: Texture2D = preload("res://assets/art/portraits/portrait_gleb_calm.png")
const GLEB_SMIRK_AVATAR: Texture2D = preload("res://assets/art/portraits/portrait_gleb_smirk.png")
const STUDENT_CALM_AVATAR: Texture2D = preload("res://assets/art/portraits/portrait_student_calm.png")

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
	(
		"Так. Пять пунктов — и доклад готов. «Кто с мечом к нам придёт…» — это в конец. "
		+ "Для пафоса."
	),
	"Забавно...",
	"Что-то смешное?",
	"Простите. Просто «тупые немцы» и «провалились» — это сильно.",
	"Это же все знают.", 
	"Вот именно. Удачи с докладом."
]

const PAGES_FOR_DIALOGUE: Array[Texture2D] = [
	CAFE_BACKGROUND,
	CAFE_BACKGROUND,
	MYTH_BACKGROUND,
	CAFE_BACKGROUND,
	NOTES_BACKGROUND,
	GLEB_BACKGROUND,
	GLEB_DIALOGUE_BACKGROUND,
	GLEB_DIALOGUE_BACKGROUND,
	GLEB_DIALOGUE_BACKGROUND,
	GLEB_DIALOGUE_BACKGROUND,
]

const AVATARS_FOR_DIALOGUE: Array[Texture2D] = [
	STUDENT_CALM_AVATAR,
	STUDENT_CALM_AVATAR,
	STUDENT_CALM_AVATAR,
	STUDENT_CALM_AVATAR,
	STUDENT_CALM_AVATAR,
	GLEB_SMIRK_AVATAR,
	STUDENT_CALM_AVATAR,
	GLEB_SMIRK_AVATAR,
	STUDENT_CALM_AVATAR,
	GLEB_CALM_AVATAR,
]

signal story_finished()

var _dialog_index: int = 0

@onready var _dialogue_text: Label = %DialogueText
@onready var _page_counter: Label = %PageCounter
@onready var _next_button: Button = %NextButton
@onready var _background: TextureRect = $BackgroundContainer/TextureRect
@onready var _avatar: TextureRect = %Portrait
@onready var _avatar_title: Label = %Speaker


func _ready() -> void:
	_show_page()
	_next_button.grab_focus()


func _show_page() -> void:
	_background.texture = PAGES_FOR_DIALOGUE[_dialog_index] if _dialog_index < PAGES_FOR_DIALOGUE.size() else null
	_dialogue_text.text = DIALOGUE_PAGES[_dialog_index]
	_page_counter.text = "%d / %d" % [_dialog_index + 1, DIALOGUE_PAGES.size()]
	_next_button.text = "Начнём!" if _dialog_index == DIALOGUE_PAGES.size() - 1 else "Далее"
	_avatar.texture = AVATARS_FOR_DIALOGUE[_dialog_index] if _dialog_index < AVATARS_FOR_DIALOGUE.size() else null
	_avatar_title.text = "Студент" if AVATARS_FOR_DIALOGUE[_dialog_index] == STUDENT_CALM_AVATAR else "Глеб"

func _on_start_button_pressed() -> void:
	if _dialog_index < DIALOGUE_PAGES.size() - 1:
		_dialog_index += 1
		_show_page()
	else:
		_next_button.disabled = true
		emit_signal("story_finished")
