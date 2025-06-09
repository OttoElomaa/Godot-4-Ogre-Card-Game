extends Node2D


@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard.tscn")

var bestiaryVisible := false



func _ready() -> void:
	
	States.statesNone()
	$Bestiary.hide()


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
	get_tree().change_scene_to_packed(GameBoardScene)


func buttonPressedToggleBestiary() -> void:
	
	if not bestiaryVisible:
		bestiaryVisible = true
		$Bestiary.show()
		
		var creatures:Array = loadCardsInFolder("res://Cards/Creatures/")
		var rituals:Array = loadCardsInFolder("res://Cards/Rituals/")
		
		var allCards = creatures
		allCards.append_array(rituals)
		
		var counter := 0
		var card:Card = null
		for slot in $Bestiary/Slots.get_children():
			if counter < allCards.size():
				card = allCards[counter]
				card.position = slot.position
				$Bestiary/Cards.add_child(card)
				
				card.turnOnBestiaryVisuals()
				
				counter += 1
			
			
		
		
