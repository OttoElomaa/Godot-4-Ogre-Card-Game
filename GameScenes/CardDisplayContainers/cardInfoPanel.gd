extends PanelContainer
class_name CardInfoPanel

const TermTooltipScene = DataLoader.scenes_by_name['TermTooltip']

var bestiary: Node = null

## If true, the panel will disappear if no card is currently hovered over.
@export var disappearing := false

@export var hasFloatyTooltips := true
@export var showLore := false


func _ready():
	if hasFloatyTooltips:
		%VBoxRight.reparent(%FloatyOffset)
		reset_size()
		#set_position(Vector2.ZERO)
		set_anchors_preset(Control.PRESET_CENTER_RIGHT, true)
		
	
	toggleCardInfo(false, null)


func bestiarySetup(bestiaryScreen:Node):
	if bestiaryScreen:
		bestiary = bestiaryScreen


func toggleStaticExplanationLabels(toShow:bool):
	%VBoxRight.visible = toShow
	self.reset_size()
	
	

func toggle_text(visiblility: bool):
	%Margin.visible = visiblility
	%CardBackgroundTexture.visible = visiblility
	%CardBottomMargin.visible = visiblility
	%TermTooltips.visible = visiblility


#### ON/OFF TOGGLE. NEEDS CARD. OPTIONAL SCREEN POSITION FOR FLOATY TOOLTIPS
func toggleCardInfo(enable:bool, card:Card, screenPosition:Vector2 = Vector2.ZERO):
	print('Toggled card info with ', card)
	var flavorTextLabel:Label = %FlavorLabel

	#### CASE 1 - HIDE
	if not enable:
		if disappearing:
			hide()
		else:
			toggle_text(false)
			%EmptySlot.show()
		return
	
	############################
	#### CASE 2 - SHOW
	show()
	print('showing')
	toggle_text(true)
	%EmptySlot.hide()
	
	#if not screenPosition == Vector2.ZERO:
	$FloatyCanvas.offset = screenPosition
	
	if showLore:
		%FlavorLabel.show()
	else:
		%FlavorLabel.hide()
	
	#### SHOW FLAVOR TEXT
	if bestiary:
		flavorTextLabel.show()
		flavorTextLabel.text = card.flavorText
	
	%NameLabel.text = card.cardName
	%CardArt.texture = card.cardArt
	%SubTypeLine.text = "%s - %s" % [card.cardTypeStr,card.subTypeStr]
	%EffectText.text = card.effectText
	
	%AttackDefenseLabel.text = "%d / %d" % [card.tempDamage,card.tempHealth]
	
	for i in %TermTooltips.get_children():
		i.queue_free()
	
	for i:String in MyTools.fetch_terms_and_explanations(card.effectText):
		var new = TermTooltipScene.instantiate() as TermTooltip
		var new_text = ''
		i = i[0].to_upper() + i.substr(1)
		new_text = str(i)
		new.set_text(new_text)
		%TermTooltips.add_child(new)
		
