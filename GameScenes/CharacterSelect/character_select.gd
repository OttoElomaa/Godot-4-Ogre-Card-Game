extends CanvasLayer

var card_container:PackedScene = preload('uid://c84qv8p8c0mxd')
var travel_screen:PackedScene = preload('uid://nmvym5570qtn')
var champ_skill_container = preload('uid://cc07uuuw1gknl')
var chosen_cause: String = ''

var Causes:Dictionary = {
	'City':
		{'champion': DataLoader.champions_by_name['General'],
		'name': 'City',
		'subtitle': 'For the Sun, the King and the Law',
		'description': 'Campaign for the [color=antique_white]City[/color], whose [color=GOLD]King[/color] champions [color=TURQUOISE]order[/color] and [color=coral]law[/color] across the continent, whose men fight for [color=]peace on earth and beyond...',
		'starting_army': [DataLoader.createCardByAmount('Kalasirios', 3), DataLoader.createCardByAmount('Ahati', 1), DataLoader.createCardByAmount('Blast', 1)],
		'map': preload("res://GameScenes/TravelMap/map_askelan.tscn"),
		'starting_dialogue': preload("res://Resources/Dialog/General_Start.dialogue"),
		'bgm': preload("res://Audio/BGM/Anghu Musica - Sun & The Lord; General's Theme.wav"),
		'location_texture': null,
		'faction_texture': null
		}
	
}


func _ready():
	%General.insert_champion(DataLoader.champions_by_name['General'])

func toggle_select_cause():
	%SelectCause.show()
	%CharacterPreview.hide()



func toggle_character_preview(champ:String):
	%SelectCause.hide()
	
	var cause = Causes[champ]
	var cause_champ:Champion = cause['champion']
	MyTools.add_child(cause_champ)
	
	print(cause_champ.usable_actions)
	%ChampContainer.insert_champion(cause_champ)
	%CharacterName.text = cause['name']
	%CharacterTitle.text = cause['subtitle']
	%Description.text = cause['description']
	
	for i:Array in cause['starting_army']:
		var new_cont = card_container.instantiate() as BestiaryContainer
		%ArmyContainer.add_child(new_cont)
		new_cont.insert_card(i[0])
		if i.size() > 1:
			for c:Card in i:
				new_cont.stack_card(c)
			new_cont.remove_topmost_card()
		new_cont.infoPanel = %CardInfoPanel
	
	var action_number = cause_champ.all_actions.size()
	
	for child in %ChampSkillContainer.get_children():
		child.queue_free()
	
	for i in cause_champ.usable_actions:
		var node = champ_skill_container.instantiate() as ChampSkillContainer
		await get_tree().process_frame
		node.setup(i)
		%ChampSkillContainer.add_child(node)
		node.show_description = true
	
	MyTools.remove_child(cause_champ)
	%CharacterPreview.show()

func _on_start_game_button_pressed():
	var cause:Dictionary = Causes[chosen_cause]
	GameInfo.current_champion = cause['champion']
	
	var unpacked_cards: Array[Card] = []
	for i:Array in cause['starting_army']:
		for a:Card in i:
			unpacked_cards.append(a)
	GameInfo.playerOwnedCards.clear()
	GameInfo.playerDeckCards = unpacked_cards
	
	var new_trav_screen: TravelScreen = travel_screen.instantiate()
	new_trav_screen.setup(cause['map'].instantiate() as Map)
	
	## Animate UI fade out and start intro.
	var tween = get_tree().create_tween()
	$CharacterPreview/MarginContainer2/VBoxContainer/HBoxContainer/StartGameButton.disabled = true
	$CharacterPreview/MarginContainer2/VBoxContainer/HBoxContainer/Back.disabled = true
	MusicBus.play(cause['bgm'])
	
	tween.tween_property(%CharacterPreview, 'modulate', Color(0.0, 0.0, 0.0, 0.0), 3.0)
	await tween.finished
	%CharacterPreview.hide()
	
	DialogueManager.show_dialogue_balloon(Causes[chosen_cause]['starting_dialogue'])
	await DialogueManager.dialogue_ended
	
	SceneSwitcher.switchToNewScene(new_trav_screen)

func _on_back_pressed():
	toggle_select_cause()


func _on_button_pressed():
	
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/MainMenu/MainMenu.tscn")


func _on_general_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("LMB"):
			
			toggle_character_preview('City')
			chosen_cause = 'City'
