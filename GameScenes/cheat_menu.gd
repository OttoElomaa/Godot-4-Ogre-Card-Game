extends Node2D
class_name CheatMenu

var current_scene
var template_card = preload("res://Cards/Cr-DebugMenuCard.tscn")
var active_cheat_scene

var new_card: Card
var found_card: Card

var all_cards = []

@onready var cardEditor := $GameBoard_Cheats/RightMenu/HBox/CardEditor
@onready var cardSearch := $GameBoard_Cheats/RightMenu/HBox/SearchCardsPanel
@onready var topMenu := $GameBoard_Cheats/TopMenu

var cardEditorVisible := false



func _ready():
	get_current_scene()
	toggleCardEditor(cardEditorVisible)
	get_all_game_cards()


func _input(event):
	if event.is_action_released("CheatButton"):
		get_current_scene()
		toggleCardEditor(!cardEditorVisible)


func toggleCardEditor(toShow:bool):
	if toShow:
		cardEditor.show()
		cardSearch.show()
		topMenu.show()
		
	else:
		cardEditor.hide()
		cardSearch.hide()
		topMenu.hide()

	cardEditorVisible = toShow

	

func get_current_scene():
	current_scene = get_tree().root.get_child(len(get_tree().root.get_children()) - 1)
	if current_scene.name == 'GameBoard':
		$GameBoard_Cheats.visible = true
		conj_card()

###########################################################################################
# GameBoard Cheats

func _on_nuke_all_cards_pressed():
	current_scene.nuke_all_cards()

func get_all_game_cards():
	var path = 'res://Cards/City/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		all_cards.append(new_card.instantiate())
	path = 'res://Cards/Desert/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		all_cards.append(new_card.instantiate())
	path = 'res://Cards/Outcasts/'
	for file in DirAccess.get_files_at('res://Cards/Outcasts/'):
		var new_card = load(str(path, file))
		all_cards.append(new_card.instantiate())
	path = 'res://Cards/GreenDefiance/'
	for file in DirAccess.get_files_at('res://Cards/GreenDefiance/'):
		var new_card = load(str(path, file))
		all_cards.append(new_card.instantiate())

func _on_add_keyword_pressed():
	new_card.addKeyword(cardEditor.get_node("VBox/NewKeyword").text) 
	update_new_card_keywords()
	
	
func update_new_card_keywords():
	new_card.getKeywords()
	cardEditor.get_node("VBox/Keywords").text = ''
	for i in new_card.keywords:
		cardEditor.get_node("VBox/Keywords").text += i.id


func finalize_card():
	cardEditor.get_node("VBox/Attack")
	new_card.startingDamage = cardEditor.get_node("VBox/HBox/Attack").text.to_int()
	new_card.startingHealth = cardEditor.get_node("VBox/HBox/HP").text.to_int()
	new_card.cardName = cardEditor.get_node("VBox/CardName").text

	add_child(new_card)


func conj_card():
	new_card = template_card.instantiate()
	new_card.hide()


func _on_to_you_pressed():
	finalize_card()
	new_card.show()
	MyTools.summonCard(new_card, false)
	conj_card()


func _on_to_foe_pressed():
	finalize_card()
	new_card.show()
	MyTools.summonCard(new_card, true)
	conj_card()

func _on_search_card_name_text_changed() -> bool:
	var prompt:String = cardSearch.get_node("VBox/SearchCardName").text
	prompt = prompt.to_lower()
	if prompt == "":
		cardSearch.get_node("VBox/CardFace").texture = null
		return false
	
	#### GET PLAYER DECK CARDS IN REAL TIME
	var playerDeckCards:Array = MyTools.getDeckCards(false) 
	for i in all_cards:
		var cardName:String = i.cardName.to_lower()
		#### IF THE LOWERCASE STRING IS CONTAINED IN LOWERCASE CARD NAME -> Success
		if cardName.contains(prompt):
			found_card = i
			cardSearch.get_node("VBox/CardFace").texture = found_card.cardArt
			return true
	
	cardSearch.get_node("VBox/CardFace").texture = null
	return false
			
			

func _on_to_foe_2_pressed():
	if found_card:
		_on_search_card_name_text_changed()
		MyTools.summonCard(found_card.duplicate(), true)

func _on_to_you_2_pressed():
	if found_card:
		_on_search_card_name_text_changed()
		MyTools.summonCard(found_card.duplicate(), false)


func _on_to_player_hand_pressed() -> void:
	if found_card:
		_on_search_card_name_text_changed()
		MyTools.addCardToHand(found_card.duplicate(), false)


func _on_to_player_graveyard_pressed() -> void:
	if found_card:
		_on_search_card_name_text_changed()
		MyTools.addCardToGraveyard(found_card.duplicate(), false)
