extends Node2D
class_name ZoneNode

var unlocked = false
var resolved = false
var timed_out = false
var travel_screen:TravelScreen = null
var myScenario: String = ''
@export var input_active = true:
	set(value):
		input_active = value
		if %PanelContainer:
			if input_active:
				%PanelContainer.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
			else:
				%PanelContainer.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE

## How many turns this node will linger. Once its duration is reached, it will be nuked (removed).
@export var duration:int = 1:
	set(value):
		duration = value
		print('changed duration to ', duration)

## If true, this node will never time out. Elite nodes don't time out even if this is off.
@export var no_timeout = false
var time_elapsed = 0

@export var node_name = ''
@export var node_comments = ''

@export var start_unlocked = false

## What nodes will be unlocked after this one is resolved. Can assign ZoneNode values.
@export var unlock_on_resolve: Array[Node] 

## What nodes will be unlocked if this one is allowed to time out. Assign ZoneNodes.
@export var unlock_on_timeout: Array[Node]

## If this is set, the player will be forced into a dialogue should this node time out.
@export var dialogue_on_timeout: DialogueResource

## If true, resolving this node will not advance a turn.
@export var free_action = false

## If true, new nodes won't appear before this one is resolved; elite nodes also do not time out.
@export var elite_node = false


func _ready():
	unlocked = start_unlocked
	if not start_unlocked:
		hide()
	if unlocked:
		unlock()

func setup(zone:Node, scenario:String):
	travel_screen = zone
	myScenario = scenario
	unlocked = start_unlocked
	toggleHoverInfo(false)
	travel_screen.updateZoneVisuals()

func get_siblings() -> Array[ZoneNode]:
	var array: Array[ZoneNode] = []
	for child in get_parent().get_children():
		array.append(child)
	return array

func node(n_name:String):
	return travel_screen.get_node_from_same_scenario(myScenario, n_name)

#### EMPTY: OVERWRITTEN IN INHERITED SCRIPTS
func handleClick():
	pass
	
#### EMPTY: OVERWRITTEN IN INHERITED SCRIPTS
func update_state():
	pass

### A Zone Node is resolved after accomplishing its functon. For example,
### a battle node is resolved when a battle is won, and a dialog node is resolved
### when the conversation within it is completed.
func resolve():
	resolved = true
	print('Resolved node ', name)
	unlock_connected()
	
	travel_screen.increment_turn()
	
### If a node is freed due to running out of time, it triggers its timeout function.
func timeout():
	print(name, ' timed out')
	%AnimationPlayer.play("timeout")
	await %AnimationPlayer.animation_finished
	for n:ZoneNode in unlock_on_timeout:
		n.unlock()
	if dialogue_on_timeout:
		DialogueManager.show_dialogue_balloon(dialogue_on_timeout)

### If 'insta-resolve' is checked in the Cheat menu, this will resolve the node
### when it's run.
func insta_resolve() -> bool:
	if Cheat.insta_resolve == true:
		resolve()
		#zone.toggleUI()
		return true
		
	#zone.toggleUI()
	return false


func getNodeName():
	var stringToCheck = node_name
	if has_method("getBoardName"):
		var battleName = call("getBoardName")
		if battleName != "":
			stringToCheck = battleName
	return stringToCheck

func can_timeout() -> bool:
	if elite_node:
		return false
	if no_timeout:
		return false
	return true

func process_turn():
	if can_timeout():
		time_elapsed += 1
		if duration - time_elapsed < 2:
			%AnimationPlayer.play("about_to_expire")
	if time_elapsed >= duration:
		timed_out = true

func toggleHoverInfo(enable:bool):
	if enable:
		$InfoPanel.show()
		$InfoPanel.z_index = 1
		$InfoPanel/HBox/NameLabel.text = getNodeName()
		if can_timeout():
			$InfoPanel/HBox/DescLabel.text = str(node_comments, '\nWill disappear after ', duration - time_elapsed, ' turns')
		
	else:
		$InfoPanel.hide()
		$InfoPanel.z_index = 0

func showCompletionState():
	$ClearedOverlay.visible = resolved

func unlock_connected():
	for n:ZoneNode in unlock_on_resolve:
		node(n.name).unlock()


### A Zone Node is visible when unlocked. Nodes can be unlocked at the start,
### by resolving other nodes, or by making right dialogue choices.
func unlock():
	print('Unlocked ZoneNode ', self)
	unlocked = true


func _on_panel_container_mouse_entered():
	toggleHoverInfo(true)

func _on_panel_container_mouse_exited():
	toggleHoverInfo(false)


func _on_panel_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("LMB"):
			handleClick()

func AnimateUnlock():
	%AnimationPlayer.play("unlock")
	await %AnimationPlayer.animation_finished
	
func AnimateResolve():
	%AnimationPlayer.play("resolve")
	await %AnimationPlayer.animation_finished
