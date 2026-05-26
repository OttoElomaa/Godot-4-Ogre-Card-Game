extends PanelContainer


var bestiary: Node = null

func _ready():
	modulate = Color(1, 1, 1, 0)


func _process(delta: float) -> void:
	var scrollContentsHeight:int = $MarginWithOuter/VBoxWithOuterText/Scroll/VBox.size.y
	var scroll := $MarginWithOuter/VBoxWithOuterText/Scroll
	
	if scrollContentsHeight > 700:
		scroll.size.y = 700
	else:
		scroll.size.y = scrollContentsHeight


func bestiarySetup(bestiaryScreen:Node):
	if bestiaryScreen:
		bestiary = bestiaryScreen


func toggleCardInfo(enable:bool, card:Card):
	var flavorTextLabel := $MarginWithOuter/VBoxWithOuterText/Scroll/VBox/FlavorLabel
	flavorTextLabel.hide()
	
	#### HIDE
	if not enable:
		modulate = Color(1, 1, 1, 0)
		if bestiary:
			#bestiary.setFlavorLabelText("")
			flavorTextLabel.text = ""
		return
		
	#### SHOW
	modulate = Color(1, 1, 1, 1)
	if bestiary:
		#bestiary.setFlavorLabelText(card.flavorText)
		flavorTextLabel.show()
		flavorTextLabel.text = card.flavorText
	
	%NameLabel.text = card.cardName
	%CardArt.texture = card.cardArt
	
	%SubTypeLine.text = "%s - %s" % [card.cardTypeStr,card.subTypeStr]
	
	#if card.effectText != "":
	%EffectText.text = card.effectText
	
	%AttackDefenseLabel.text = "%d / %d" % [card.tempDamage,card.tempHealth]
	
	%ExplanationLabel.clear()
	for i:String in MyTools.fetch_terms_and_explanations(card.effectText):
		i = i[0].to_upper() + i.substr(1)
		%ExplanationLabel.append_text(str(i, '[br]'))
		
