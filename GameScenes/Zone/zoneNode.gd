extends Node2D
class_name ZoneNode

var unlocked = false
var resolved = false

@export var node_name = ''
@export var node_comments = ''

@export var start_unlocked = false
@export var unlock_on_resolve: Array[Node] 

func _ready():
	unlocked = start_unlocked
	visible = unlocked
	update_state()

func resolve():
	resolved = true
	showCompletionState()
	unlock_connected()

func unlock():
	visible = true
	
func _on_area_2d_mouse_entered() -> void:
	toggleHoverInfo(true)


func _on_area_2d_mouse_exited() -> void:
	toggleHoverInfo(false)

func toggleHoverInfo(enable:bool):
	if enable:
		$InfoPanel.show()
		$InfoPanel/HBox/NameLabel.text = node_name
		$InfoPanel/HBox/DescLabel.text = node_comments
	else:
		$InfoPanel.hide()

func showCompletionState():
	$ClearedOverlay.visible = resolved

func unlock_connected():
	for n:ZoneNode in unlock_on_resolve:
		n.unlock()

func update_state():
	pass

func insta_resolve():
	if Cheat.insta_resolve == true:
		resolve()
		return
