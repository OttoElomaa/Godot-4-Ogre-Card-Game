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

	var levels = DataLoader.scenarios_by_location
	if levels.is_empty():
		$VBox/NoLevelsLabel.show()
		return
	$VBox/NoLevelsLabel.hide()
	
	for level in levels:
		var listButton := _make_button(level)
		rows.add_child(listButton)


func _make_button(scenario: Scenario) -> ClickableListItem:
	var listButton: ClickableListItem = ListButtonScene.instantiate()
	#### PASS A FUNCTION WITH THE ID SET AS PARAM
	var pressedFunction:Callable = func(): GameInfo.currentZone.place_scenario(scenario)
	var description := "%s: %s" % [scenario.name, scenario.scenario_type]
	
	listButton.setup(scenario.name, pressedFunction, description)
	return listButton



func buttonPressedToggleVisibility() -> void:
	toggleVisibility(!visible)
