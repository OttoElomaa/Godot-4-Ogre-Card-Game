extends Node2D


var storedSceneB:Node = null
var currentSceneA:Node = null

var sceneTree:SceneTree = null

const GameScenePath = "res://GameScenes/"

func _ready() -> void:
	sceneTree = get_tree()


func getCurrentScene():
	return get_tree().root.get_children()[sceneTree.root.get_children().size() - 1]

func switchToNewScene(newSceneB:Node):
	var currScene = getCurrentScene()
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + newSceneB.name)
	
	storedSceneB = currScene
	currentSceneA = newSceneB
	
	if newSceneB.is_inside_tree():
		newSceneB.reparent.call_deferred(sceneTree.root)
	else:
		sceneTree.root.add_child.call_deferred(newSceneB)
	sceneTree.root.remove_child.call_deferred(storedSceneB)

func switchToNewSceneFromFile(path:String):
	var currScene = getCurrentScene()
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + path)
	
	storedSceneB = currScene
	var s = load(path)
	var newSceneB = s.instantiate()
	
	get_tree().root.add_child.call_deferred(newSceneB)
	get_tree().root.remove_child.call_deferred(storedSceneB)

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
	
func returnToMainMenu():
	switchToNewSceneFromFile("res://GameScenes/MainMenu/MainMenu.tscn")
	
func openScene(newScene:Node):
	getCurrentScene().add_child.call_deferred(newScene)

func closeScene(Scene:Node):
	getCurrentScene().remove_child.call_deferred(Scene)
