extends ZoneBattleIcon

var fight_number = 0

func resolve():
	generate_fight()
	fight_number += 1
	board_name = str(board_name, ' +', fight_number)

func generate_fight():
	board = game_board.instantiate().duplicate()
	add_child(board)
	await get_tree().process_frame
	board.boardName = board_name
	board.AI_personality = ai_personality
	
	var all_cards = GameInfo.all_cards
	var mana_cost = 1
	var cards_for_preview = []
	
	board.nuke_cards(true)
	board.nuke_cards(false)
	
	for i in range(4):
		var cards_in_tier = []
		for card:Card in all_cards:
			if card.manaCost == mana_cost and card.isRitual == false:
				cards_in_tier.append(card)
		mana_cost += 1
		var new_card:Card = cards_in_tier.pick_random()
		cards_for_preview.append(new_card.duplicate())
		for n in range(4):
			board.add_card_to_enemy_deck(new_card.duplicate())
	
	for i in range(2):
		var rituals = []
		for card:Card in all_cards:
			if card.isRitual:
				rituals.append(card)
		var new_card:Card = rituals.pick_random()
		cards_for_preview.append(new_card.duplicate())
		for n in range(4):
			board.add_card_to_enemy_deck(new_card.duplicate())
	
	board.setup_board()
	board.turn_1_init()
	remove_child(board)
	
	return cards_for_preview
