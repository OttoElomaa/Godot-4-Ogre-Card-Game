extends Node2D
class_name ZoneNode

var unlocked = false
var resolved = false
var scenario:Scenario = null

@export var node_name = ''
@export var node_comments = ''

@export var start_unlocked = false

## What nodes will be unlocked after this one is resolved. Can assign ZoneNode values.
@export var unlock_on_resolve: Array[Node] 
## What nodes will be unlocked after this one is resolved. Can assign String values; unlocks nodes with that node_name.
@export var unlockOnResolveStrings: Array[String]

func _ready():
	unlocked = start_unlocked
	if unlocked:
		show()
	else:
		hide()
	update_state()

func setup(zone:Node):
	self.scenario = zone
	toggleHoverInfo(false)



func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	
	if event.is_action_pressed("LMB"):
		if not getNodeName() in GameInfo.playerWonBattleNames:
			if not insta_resolve():  #### CHEAT MENU - SKIP NODE GAMEPLAY
				handleClick()        #### PROCEED WITH NODE GAMEPLAY



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
	GameInfo.playerWonBattleNames.append(getNodeName())
	showCompletionState()
	unlock_connected()


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



	
func _on_area_2d_mouse_entered() -> void:
	toggleHoverInfo(true)


func _on_area_2d_mouse_exited() -> void:
	toggleHoverInfo(false)

func toggleHoverInfo(enable:bool):
	if enable:
		$InfoPanel.show()
		$InfoPanel.z_index = 1
		$InfoPanel/HBox/NameLabel.text = getNodeName()
		$InfoPanel/HBox/DescLabel.text = node_comments
	else:
		$InfoPanel.hide()
		$InfoPanel.z_index = 0

func showCompletionState():
	$ClearedOverlay.visible = resolved

func unlock_connected():
	for n:ZoneNode in unlock_on_resolve:
		n.unlock()
	for n:String in unlockOnResolveStrings:
		scenario.unlockNode(n)


### A Zone Node is visible when unlocked. Nodes can be unlocked at the start,
### by resolving other nodes, or by making right dialogue choices.
func unlock():
	show()
