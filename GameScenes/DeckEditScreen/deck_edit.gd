extends CanvasLayer
@onready var CardContainer = preload("res://GameScenes/DeckEditScreen/card_container_draggable.tscn")
@onready var CardPanel = preload("res://GameScenes/DeckEditScreen/card_panel.tscn")
@onready var ChampActionCont = preload("res://GameScenes/DeckEditScreen/champ_skill_container.tscn")
@onready var ownedCardsContainer = %OwnedCardsContainer
@onready var activeCardsContainer = %ActiveCardsContainer
@onready var cardInfoPanel = %CardInfoPanelFloaty

var prepared_board: GameBoard = null


func _ready():
#	prepared_board = null
	update_champion()
	create_containers()
	activeCardsContainer.connect("updated", create_containers)
	ownedCardsContainer.connect("updated", create_containers)
	if prepared_board is GameBoard:
		%Proceed.show()
	else:
		%Proceed.hide()
		
func setup(board:GameBoard):
	print('Deck Edit Sets Up. Board is ', board)
	prepared_board = board
	if prepared_board is GameBoard:
		%Proceed.show()
	else:
		%Proceed.hide()

func create_containers():
	#### EMPTY THE CARD LISTS BEFORE FILLING THEM
	for child in activeCardsContainer.get_children():
		child.queue_free()
	for child in ownedCardsContainer.get_children():
		child.queue_free()
		
	print('Creating containers')
	for i:Card in GameInfo.playerOwnedCards:
		var new_cont = CardContainer.instantiate()
		ownedCardsContainer.add_child(new_cont)
		new_cont.insert_card(i)
		new_cont.infoPanel = cardInfoPanel
	for i in GameInfo.playerDeckCards:
		var new_cont = CardPanel.instantiate()
		new_cont.card = i
		activeCardsContainer.add_child(new_cont)
		
	%"#CardsInDeck".text = str(GameInfo.playerDeckCards.size(), " / 10")
	#$ProceedButton.disabled = GameInfo.playerDeckCards.size() < 10


func _on_proceed_button_button_up():
	GameInfo.isPreBattle = false
	MyTools.closeDeckEdit()
	SceneSwitcher.switchToNewScene(prepared_board)
	await get_tree().process_frame
#	prepared_board.setup_board()
#	prepared_board.turn_1_init()
	prepared_board = null

func update_champion():
	var champion = GameInfo.current_champion.duplicate()
	await MyTools.createTempCard(champion)
	%ChampionTexture.texture = champion.texture
	%ChampionName.text = champion.cardName
	for action in champion.usable_actions:
		var new_cont:ChampSkillContainer = ChampActionCont.instantiate()
		new_cont.setup(action)
		%SkillContainer.add_child(new_cont)
	MyTools.removeTempCard(champion)

func _button_up_back_to_world() -> void:
	GameInfo.isPreBattle = false
	MyTools.closeDeckEdit()
