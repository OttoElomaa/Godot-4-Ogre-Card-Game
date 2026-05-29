extends PanelContainer
class_name CheatLevelMenu


@onready var ListButtonScene:PackedScene = preload("res://GameAutoloads/Components/ClickableListItem.tscn")
@export var rows: VBoxContainer   # VBoxContainer or HBoxContainer


func _ready() -> void:
	assert(rows != null, "LevelMenu: button_container not set")
	visibility_changed.connect(_on_visibility_changed)
	hide()


func toggleVisibility(enable:bool):
	self.visible = enable


func _on_visibility_changed() -> void:
	if visible:
		_build_buttons()

func _build_buttons() -> void:
	# Clear existing
	for child in rows.get_children():
		child.queue_free()

	var levels = LevelLoader.getAllLevels()
	if levels.is_empty():
		$VBox/NoLevelsLabel.show()
		return
	$VBox/NoLevelsLabel.hide()
	
	for level in levels:
		var listButton := _make_button(level)
		rows.add_child(listButton)


func _make_button(level: Dictionary) -> ClickableListItem:
	var listButton: ClickableListItem = ListButtonScene.instantiate()
	#### PASS A FUNCTION WITH THE ID SET AS PARAM
	var pressedFunction:Callable = func(): LevelLoader.changeTo(level.id) 
	var description := "%s: %s" % [level.category, level.display_name]
	
	listButton.setup(level.display_name, pressedFunction, description)
	return listButton



func buttonPressedToggleVisibility() -> void:
	toggleVisibility(!visible)
