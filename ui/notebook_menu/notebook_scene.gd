class_name NotebookScene
extends Control

@export var tabs_group: ButtonGroup = ButtonGroup.new()
@export var items_group: ButtonGroup = ButtonGroup.new()

@onready var tab1: TabNameItem = %StoriesTab as TabNameItem
@onready var tab2: TabNameItem = %FindingsTab as TabNameItem

@onready var item_1: EntityItem = %Item_1 as EntityItem
@onready var item_2: EntityItem = %Item_2 as EntityItem
@onready var item_3: EntityItem = %Item_3 as EntityItem
@onready var item_4: EntityItem = %Item_4 as EntityItem
@onready var item_5: EntityItem = %Item_5 as EntityItem

func _ready() -> void:
    tab1.button_group = tabs_group
    tab2.button_group = tabs_group

    tab1.set_tab_name("Заметки")
    tab2.set_tab_name("Находки")

    tab1.toggled.connect(_on_tab_changed)
    tab2.toggled.connect(_on_tab_changed)

    tab1.button_pressed = true

    item_1.button_group = items_group
    item_2.button_group = items_group
    item_3.button_group = items_group
    item_4.button_group = items_group
    item_5.button_group = items_group

    item_1.button_pressed = true

func _on_tab_changed(_is_on: bool) -> void:
    print(_is_on)
