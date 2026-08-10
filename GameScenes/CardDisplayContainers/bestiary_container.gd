extends CardContainer
class_name BestiaryContainer

var infoPanel = null
var stacked_cards = []
var stack_number: int:
	get():
		return stacked_cards.size()

func _ready():
	update_card_stacks()

func _on_mouse_entered():
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.start(3.0)
	else:
		infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.stop()
	infoPanel.toggleCardInfo(false, null)
	
func _on_info_panel_timer_timeout():
	infoPanel.toggleCardInfo(true, card)
	infoPanel.show_at(global_position)

func stack_card(checking_card:Card) -> bool:
	if checking_card.cardName == card.cardName and checking_card.upgraded == card.upgraded:
		stacked_cards.append(checking_card)
		update_card_stacks()
		return true
	return false

func update_card_stacks():
	if stack_number > 0:
		%NumberLabel.text = str('x', stack_number + 1)
		%NumberLabel.show()
	else:
		%NumberLabel.hide()
