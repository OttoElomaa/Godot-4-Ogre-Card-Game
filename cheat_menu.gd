extends Node2D
class_name CheatMenu

var current_scene
var template_card = preload('res://Cards/Wilds/Cr-Pikeman.tscn')
var active_cheat_scene

var new_card: Card

func _ready():
	get_current_scene()

func _input(event):
	if event.is_action_released("CheatButton"):
		$GameBoard_Cheats.visible = !visible
		get_current_scene()
		visible = !visible
		

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
	new_card.addKeyword($GameBoard_Cheats/MarginContainer/NinePatchRect/NewKeyword.text) 
	update_new_card_keywords()
	
func update_new_card_keywords():
	new_card.getKeywords()
	$GameBoard_Cheats/MarginContainer/NinePatchRect/Keywords.text = ''
	for i in new_card.keywords:
		$GameBoard_Cheats/MarginContainer/NinePatchRect/Keywords.text += i.effect_shortname

func finalize_card():
	new_card.damage = $GameBoard_Cheats/MarginContainer/NinePatchRect/Attack.text.to_int()
	new_card.health = $GameBoard_Cheats/MarginContainer/NinePatchRect/HP.text.to_int()
	new_card.cardName = $GameBoard_Cheats/MarginContainer/NinePatchRect/CardName.text

func conj_card():
	new_card = template_card.instantiate()

func _on_to_you_pressed():
	finalize_card()
	current_scene.add_card_to_board('player', new_card)
	conj_card()

func _on_to_foe_pressed():
	finalize_card()
	current_scene.add_card_to_board('enemy', new_card)
	conj_card()
