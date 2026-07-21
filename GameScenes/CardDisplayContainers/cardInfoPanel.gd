extends PanelContainer

const term_tooltip = DataLoader.scenes_by_name['TermTooltip']

var bestiary: Node = null

## If true, the panel will disappear if no card is currently hovered over.
@export var disappearing = false

## If true, shows the card's flavor text underneath.
@export var show_flavor_text = false

func _ready():
	toggleCardInfo(false, null)


func _process(delta: float) -> void:
#	var scrollContentsHeight:int = $MarginWithOuter/VBoxWithOuterText/Scroll/VBox.size.y
#	var scroll := $MarginWithOuter/VBoxWithOuterText/Scroll
	
#	if scrollContentsHeight > 700:
#		scroll.size.y = 700
#	else:
#		scroll.size.y = scrollContentsHeight
	pass


func bestiarySetup(bestiaryScreen:Node):
	if bestiaryScreen:
		bestiary = bestiaryScreen

func toggle_text(visiblility: bool):
	%Margin.visible = visiblility
	%CardBackgroundTexture.visible = visiblility
	%CardBottomMargin.visible = visiblility
	%TermTooltips.visible = visiblility

func toggleCardInfo(enable:bool, card:Card):
	print('Toggled card info with ', card)
	var flavorTextLabel := %FlavorLabel
	flavorTextLabel.hide()

	#### HIDE
	if not enable:
		if disappearing:
			hide()
			if bestiary:
				#bestiary.setFlavorLabelText("")
				flavorTextLabel.text = ""
		else:
			toggle_text(false)
			%EmptySlot.show()
		return
		
	#### SHOW
	if show_flavor_text:
		%FlavorLabel.show()
	
	show()
	print('showing')
	toggle_text(true)
	%EmptySlot.hide()
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
	
	for i in %TermTooltips.get_children():
		i.queue_free()
	
	for i:String in MyTools.fetch_terms_and_explanations(card.effectText):
		var new = term_tooltip.instantiate() as TermTooltip
		var new_text = ''
		i = i[0].to_upper() + i.substr(1)
		new_text = str(i)
		new.set_text(new_text)
		%TermTooltips.add_child(new)
		
