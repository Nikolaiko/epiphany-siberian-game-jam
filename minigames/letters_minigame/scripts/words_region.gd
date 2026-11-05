class_name LettersRegion
extends LetterParent

@export var rows: Array[CellsRow]
@export var words: Array[WordItem]

var level_words: Array[String] = ["горох", "огород", "массив", "город", "космос", "огурец"]

var dragging = false

var null_vector: Vector2 = Vector2(-100, -100)
var start_dragging_position: Vector2 = null_vector
var end_dragging_position: Vector2 = null_vector

@onready var line_between_letters: Line2D = $Line2D


func _ready() -> void:
	line_between_letters.visible = false


func on_letter_pressed(row: int, column: int):
	line_between_letters.add_point(get_local_mouse_position())
	line_between_letters.add_point(get_local_mouse_position())
	line_between_letters.visible = true

	start_dragging_position = Vector2(row, column)
	dragging = true


func on_letter_released():
	dragging = false

	line_between_letters.clear_points()
	line_between_letters.visible = false

	var selected_word = check_line_coordinates()
	var index = level_words.find(selected_word)
	if index != -1:
		level_words.remove_at(index)
		for i in range(words.size()):
			if words[i].get_word() == selected_word:
				words[i].set_word("")


func on_letter_hover_on(row: int, column: int):
	end_dragging_position = Vector2(row, column)


func on_letter_hover_out(_row: int, _column: int):
	end_dragging_position = null_vector


func _process(_delta: float) -> void:
	if dragging:
		line_between_letters.points[1] = get_local_mouse_position()


func set_level_words(initial_words: Array[String]):
	level_words = initial_words


func start_game():
	for i in range(words.size()):
		words[i].set_word(level_words[i])

	for i in range(level_words.size()):
		var letters = level_words[i].split("")
		for j in range(letters.size()):
			rows[i].row_cells[j].set_letter(letters[j])


func check_line_coordinates() -> String:
	if start_dragging_position == null_vector or end_dragging_position == null_vector:
		return ""

	var total_word = ""

	if start_dragging_position.x == end_dragging_position.x:
		for index in range(start_dragging_position.y, end_dragging_position.y + 1):
			total_word += rows[start_dragging_position.x].row_cells[index].letter
			#print(rows[start_dragging_position.x].row_cells[index].letter)
	elif start_dragging_position.y == end_dragging_position.y:
		for index in range(start_dragging_position.x, end_dragging_position.x + 1):
			total_word += rows[index].row_cells[start_dragging_position.y].letter
			#print(rows[index].row_cells[start_dragging_position.y].letter)

	return total_word
