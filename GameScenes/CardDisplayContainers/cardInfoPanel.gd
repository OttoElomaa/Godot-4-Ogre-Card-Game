extends PanelContainer


var bestiary: Node = null

func _ready():
	modulate = Color(1, 1, 1, 0)

func bestiarySetup(bestiaryScreen:Node):
	if bestiaryScreen:
		bestiary = bestiaryScreen


func toggleCardInfo(enable:bool, card:Card):
	
	#### HIDE
	if not enable:
		modulate = Color(1, 1, 1, 0)
		if bestiary:
			bestiary.setFlavorLabelText("")
		return
		
	#### SHOW
	modulate = Color(1, 1, 1, 1)
	if bestiary:
		bestiary.setFlavorLabelText(card.flavorText)
	
	$Margin/VBox/NameLabel.text = card.cardName
	$Margin/VBox/ArtMargin/CardArt.texture = card.cardArt
	
	$Margin/VBox/VBox2/SubTypeLine.text = "%s - %s" % [card.cardTypeStr,card.subTypeStr]
	
	#if card.effectText != "":
	$Margin/VBox/VBox2/EffectText.text = card.effectText
	
	%AttackDefenseLabel.text = "%d / %d" % [card.tempDamage,card.tempHealth]
	
	%ExplanationLabel.clear()
	for i:String in MyTools.fetch_terms_and_explanations(card.effectText):
		i = i[0].to_upper() + i.substr(1)
		%ExplanationLabel.append_text(str(i, '[br]'))
		
