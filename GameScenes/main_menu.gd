extends Node2D


@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard.tscn")

var bestiaryVisible := false



func _ready() -> void:
	
	States.statesNone()
	$Bestiary.hide()



func _input(event: InputEvent) -> void:
	
	if bestiaryVisible:
		if event.is_action_pressed("ui_down"):
			$MenuCamera.position += Vector2.DOWN * 50
		elif event.is_action("scrollDown"):
			$MenuCamera.position += Vector2.DOWN * 50	
			
		elif event.is_action_pressed("ui_up"):
			$MenuCamera.position += Vector2.UP * 50
		elif event.is_action("scrollUp"):
			$MenuCamera.position += Vector2.UP * 50
	



func loadCardsInFolder(folderPath:String) -> Array:
	
	var dir := DirAccess.open(folderPath)
	var file_names := dir.get_files()
	var cardScenes := []
	
	for name in file_names:
		var card:PackedScene = load(folderPath + name)
		cardScenes.append(card.instantiate() ) 
	return cardScenes
	



func buttonPressedStartMatch() -> void:
	
	#var gameBoard: GameBoard = GameBoardScene.instantiate()
	bestiaryVisible = false
	get_tree().change_scene_to_packed(GameBoardScene)


func buttonPressedToggleBestiary() -> void:
	
	if not bestiaryVisible:
		bestiaryVisible = true
		$Bestiary.show()
		
		var allCards:Array = loadCardsInFolder("res://Cards/Depths/")
		allCards.append_array( loadCardsInFolder("res://Cards/GreenDefiance/") )
		allCards.append_array( loadCardsInFolder("res://Cards/Wilds/") )
		
		
		var counter := 0
		var card:Card = null
		for slot in $Bestiary/Slots.get_children():
			if counter < allCards.size():
				card = allCards[counter]
				card.position = slot.position
				$Bestiary/Cards.add_child(card)
				
				card.turnOnBestiaryVisuals()
				
				counter += 1
			
			
		
		


func buttonPressedExitGame() -> void:
	get_tree().quit()
