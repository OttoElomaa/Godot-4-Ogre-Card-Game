extends Node2D


var storedSceneB:Node = null
var currentSceneA:Node = null

var sceneTree:SceneTree = null

const GameScenePath = "res://GameScenes/"

func _ready() -> void:
	sceneTree = get_tree()

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_up"):
		#switchToStoredScene()
		#switchToNewScene(storedSceneB, currentSceneA)
		

func switchToNewScene(newSceneB:Node, currScene:Node):
	
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + newSceneB.name)
	
	storedSceneB = currScene
	currentSceneA = newSceneB
	
	sceneTree.root.add_child.call_deferred(newSceneB)
	sceneTree.current_scene = newSceneB
	sceneTree.root.remove_child.call_deferred(storedSceneB)

func switchToNewSceneFromFile(path:String, currScene:Node):
	print("Switching to a new scene.")
	print("From: " + currScene.name)
	print("To: " + path)
	
	storedSceneB = currScene
	var full_path = GameScenePath + path + '.tscn'
	var s = load(full_path)
	var newSceneB = s.instantiate()
	
	sceneTree.root.add_child.call_deferred(newSceneB)
	sceneTree.current_scene = newSceneB
	sceneTree.root.remove_child.call_deferred(storedSceneB)

func switchToStoredScene():
	print("Switching to a stored scene.")
	print("From: " + currentSceneA.name)
	print("To: " + storedSceneB.name)
	
	var sceneToSwitchIntoB = storedSceneB
	storedSceneB = currentSceneA
	currentSceneA = sceneToSwitchIntoB
	
	sceneTree.root.add_child(sceneToSwitchIntoB)
	sceneTree.current_scene = sceneToSwitchIntoB
	sceneTree.root.remove_child(storedSceneB)
	

	
