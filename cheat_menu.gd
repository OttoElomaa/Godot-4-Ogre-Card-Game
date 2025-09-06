extends Node2D
class_name CheatMenu

var current_scene
var template_card = preload('res://Cards/Wilds/Cr-Pikeman.tscn')
var active_cheat_scene

var new_card: Card
var found_card: Card

var all_cards = []

@onready var cheatPanel := $GameBoard_Cheats/Margin/CheatPanel
@onready var topMenu := $GameBoard_Cheats/TopMenu

var cardEditorVisible := false



func _ready():
	get_current_scene()
	toggleCardEditor(cardEditorVisible)


func _input(event):
	if event.is_action_released("CheatButton"):
		get_current_scene()
		toggleCardEditor(!cardEditorVisible)


func toggleCardEditor(toShow:bool):
	if toShow:
		cheatPanel.show()
<<<<<<< Updated upstream
		topMenu.show()
	else:
		cheatPanel.hide()
		topMenu.hide()
=======
		$GameBoard_Cheats/Margin2/CheatPanel2.show()
	else:
		cheatPanel.hide()
		$GameBoard_Cheats/Margin2/CheatPanel2.hide()
>>>>>>> Stashed changes
		
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


func _on_add_keyword_pressed():
	new_card.addKeyword(cheatPanel.get_node("VBox/NewKeyword").text) 
	update_new_card_keywords()
	
	
func update_new_card_keywords():
	new_card.getKeywords()
	cheatPanel.get_node("VBox/Keywords").text = ''
	for i in new_card.keywords:
		cheatPanel.get_node("VBox/Keywords").text += i.effect_shortname


func finalize_card():
	cheatPanel.get_node("VBox/Attack")
	new_card.startingDamage = cheatPanel.get_node("VBox/HBox/Attack").text.to_int()
	new_card.startingHealth = cheatPanel.get_node("VBox/HBox/HP").text.to_int()
	new_card.cardName = cheatPanel.get_node("VBox/CardName").text

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

func _on_search_card_name_text_changed():
	var prompt = $GameBoard_Cheats/Margin2/CheatPanel2/VBox/SearchCardName.text
	for i in GameInfo.playerDeckCards:
		if i.cardName == prompt:
			found_card = i
			$GameBoard_Cheats/Margin2/CheatPanel2/VBox/CardFace.texture = found_card.cardArt

func _on_to_foe_2_pressed():
	if found_card:
		MyTools.summonCard(found_card, true)

func _on_to_you_2_pressed():
	if found_card:
		MyTools.summonCard(found_card, false)
