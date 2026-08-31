@icon('uid://3hkmkavdo0dx')
extends Node2D


var storedSceneB:Node = null
var currentSceneA:Node = null

var sceneTree:SceneTree = null

const GameScenePath = "res://GameScenes/"

enum TransitionTypes {NONE, ## Default value. No transition.
SHUTTER, ## Two vanes closing in the middle.
CITY_STYLE, ## Ask'Lan style animation. Used when entering the location.
}

var transitions: Dictionary[TransitionTypes, PackedScene] = {
	TransitionTypes.SHUTTER: preload("uid://cpi52dke3d1ak"),
	TransitionTypes.CITY_STYLE: preload("uid://d1qdaj85ukqwy")
}

signal scene_changed

func _ready() -> void:
	sceneTree = get_tree()

func get_transition(trans: TransitionTypes) -> TransitionAnimation:
	var chosen = transitions[trans].instantiate() as TransitionAnimation
	get_tree().root.add_child(chosen)
	return chosen

func transition_close(anim: TransitionAnimation):
	disable_buttons()
	await anim.play_animation_close()

func disable_buttons():
	for b:Button in get_tree().get_nodes_in_group('buttons'):
		print(get_tree().get_nodes_in_group('buttons'))
		b.disabled = true


func transition_open(anim: TransitionAnimation):
	get_tree().root.move_child(anim, -1)
	await anim.play_animation_open()
	anim.queue_free()

func getCurrentScene():
	return get_tree().root.get_children()[sceneTree.root.get_children().size() - 1]

func switchToNewScene(newSceneB:Node, transition: TransitionTypes = TransitionTypes.NONE):
	var currScene = getCurrentScene()
	var transAnim = null
	var animate_transition = false
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + newSceneB.name)
	
	storedSceneB = currScene
	currentSceneA = newSceneB
	
	if not transition == TransitionTypes.NONE:
		transAnim = get_transition(transition)
		await transition_close(transAnim)
	
	if newSceneB.is_inside_tree():
		newSceneB.reparent.call_deferred(sceneTree.root)
	else:
		sceneTree.root.add_child.call_deferred(newSceneB)
	sceneTree.root.remove_child.call_deferred(storedSceneB)
	
	if transAnim:
		await transition_open(transAnim)
	
	await get_tree().process_frame
	scene_changed.emit()

func switchToNewSceneFromFile(path:String, transition: TransitionTypes = TransitionTypes.NONE):
	var currScene = getCurrentScene()
	var transAnim = null
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + path)
	
	if not transition == TransitionTypes.NONE:
		transAnim = get_transition(transition)
		await transition_close(transAnim)
	
	storedSceneB = currScene
	var s = load(path)
	var newSceneB = s.instantiate()
	
	get_tree().root.add_child.call_deferred(newSceneB)
	get_tree().root.remove_child.call_deferred(storedSceneB)
	
	if transAnim:
		await transition_open(transAnim)
	
	await get_tree().process_frame
	scene_changed.emit()

func switchToStoredScene():
	var currentSceneA = getCurrentScene()
#	print("Switching to a stored scene.")
#	print("From: " + currentSceneA.name)
#	print("To: " + storedSceneB.name)
	
	var sceneToSwitchIntoB = storedSceneB
	storedSceneB = currentSceneA
	currentSceneA = sceneToSwitchIntoB
	
	sceneTree.root.add_child(sceneToSwitchIntoB)
	sceneTree.root.remove_child(storedSceneB)
	await get_tree().process_frame
	scene_changed.emit()
	
func returnToMainMenu():
	switchToNewSceneFromFile("res://GameScenes/MainMenu/MainMenu.tscn")
	await get_tree().process_frame
	scene_changed.emit()
	
func openScene(newScene:Node):
	getCurrentScene().add_child.call_deferred(newScene)
	await get_tree().process_frame
	scene_changed.emit()

func closeScene(Scene:Node):
	getCurrentScene().remove_child.call_deferred(Scene)
	await get_tree().process_frame
	scene_changed.emit()
