extends LetterParent

class_name LettersRegion

@export var rows: Array[CellsRow]
@export var words: Array[WordItem]

@onready var lineBetweenLetters: Line2D = $Line2D

var levelWords: Array[String] = ["горох", "огород", "массив", "город", "космос", "огурец"]

var dragging = false

var nullVector: Vector2 = Vector2(-100, -100)
var startDraggingPosition: Vector2 = nullVector
var endDraggingPosition: Vector2 = nullVector

func _ready() -> void:
	lineBetweenLetters.visible = false
	
	#call_deferred("initGamePole")


func onLetterPressed(row: int, column: int):		
	lineBetweenLetters.add_point(get_local_mouse_position())
	lineBetweenLetters.add_point(get_local_mouse_position())
	lineBetweenLetters.visible = true
	
	startDraggingPosition = Vector2(row, column)
	dragging = true

func onLetterReleased():
	dragging = false
	
	lineBetweenLetters.clear_points()
	lineBetweenLetters.visible = false
	
	var selectedWord = checkLineCoordinates()
	var index = levelWords.find(selectedWord)
	if (index != -1):
		levelWords.remove_at(index)
		for i in range(words.size()):
			if (words[i].getWord() == selectedWord):
				words[i].setWord("")
	
func onLetterHoverOn(row: int, column: int):
	endDraggingPosition = Vector2(row, column)

func onLetterHoverOut(row: int, column: int):
	endDraggingPosition = nullVector
	
func _process(delta: float) -> void:
	if (dragging):
		lineBetweenLetters.points[1] = get_local_mouse_position()

func initGamePole():
	
	for i in range(words.size()):
		words[i].setWord(levelWords[i])
	
	for i in range(levelWords.size()):
		var letters = levelWords[i].split("")
		for j in range(letters.size()):
			rows[i].rowCells[j].setLetter(letters[j])

func checkLineCoordinates() -> String:
	if (startDraggingPosition == nullVector or endDraggingPosition == nullVector):
		return ""
	
	var totalWord = ""
	
	if (startDraggingPosition.x == endDraggingPosition.x):		
		for index in range(startDraggingPosition.y, endDraggingPosition.y + 1):
			totalWord += rows[startDraggingPosition.x].rowCells[index].letter
			#print(rows[startDraggingPosition.x].rowCells[index].letter)
	elif (startDraggingPosition.y == endDraggingPosition.y):
		for index in range(startDraggingPosition.x, endDraggingPosition.x + 1):
			totalWord += rows[index].rowCells[startDraggingPosition.y].letter
			#print(rows[index].rowCells[startDraggingPosition.y].letter)
			
	return totalWord
