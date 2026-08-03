@tool
extends ZoneBattleIcon

var fight_number = 0

func resolve():
	queue_free()

func generate_fight():
	if game_board:
		board = game_board.instantiate().duplicate()
	board.boardName = board_name
	board.AI_personality = ai_personality
	
	var all_cards = GameInfo.all_cards
	var mana_cost = 1
	var cards_for_preview = []
	
	GameInfo.enemyDeckCards.clear()
	print('Clearing enemyDeckCards')
	
	for i in range(4):
		var cards_in_tier = []
		for card:Card in all_cards:
			if card.manaCost == mana_cost and card.isRitual == false:
				cards_in_tier.append(card)
		mana_cost += 1
		var new_card:Card = cards_in_tier.pick_random()
		cards_for_preview.append(new_card.duplicate())
		for n in range(4):
			GameInfo.enemyDeckCards.append(new_card.duplicate())
	
	for i in range(2):
		var rituals = []
		for card:Card in all_cards:
			if card.isRitual:
				rituals.append(card)
		var new_card:Card = rituals.pick_random()
		cards_for_preview.append(new_card.duplicate())
		for n in range(4):
			GameInfo.enemyDeckCards.append(new_card.duplicate())
	
	return cards_for_preview
