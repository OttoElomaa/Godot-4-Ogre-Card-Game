extends PanelContainer





func toggleCardInfo(enable:bool, card:Card):
	
	#### HIDE
	if not enable:
		hide()
		return
		
	#### SHOW
	show()
	$Margin/VBox/NameLabel.text = card.cardName
	$Margin/VBox/CardArt.texture = card.cardArt
	
	$Margin/VBox/VBox2/SubTypeLine.text = "%s - %s" % [card.cardTypeStr,card.subTypeStr]
	
	#if card.effectText != "":
	$Margin/VBox/VBox2/EffectText.text = card.effectText
	
	
	$Margin/VBox/VBox2/FlavorTextLabel.text = card.flavorText
	
	$Margin/AttackDefenseLabel.text = "%d / %d" % [card.tempDamage,card.tempHealth]
	
