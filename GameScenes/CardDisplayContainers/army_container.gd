extends Container
class_name ArmyContainer

var card_container = preload("res://GameScenes/CardDisplayContainers/BestiaryContainer.tscn")

## Can accept armies formatted as Array[Card] or Array[Array[Card]].
func insert_army(army:Array, info_panel:Node = null):
	if army[0] is Array:
		for i:Array in army:
			
			var new_cont = card_container.instantiate() as BestiaryContainer
			add_child(new_cont)
			new_cont.insert_card(i[0])
			if i.size() > 1:
				for c:Card in i:
					new_cont.stack_card(c)
				new_cont.remove_topmost_card()
			new_cont.infoPanel = info_panel
	elif army[0] is Card:
		for i:Card in army:

			var has_same = false
			for c:BestiaryContainer in get_children():
				if c.stack_card(i):
					has_same = true
					break

			if has_same == false:
				var new_cont = card_container.instantiate() as BestiaryContainer
				add_child(new_cont)
				new_cont.insert_card(i)
				new_cont.infoPanel = info_panel
