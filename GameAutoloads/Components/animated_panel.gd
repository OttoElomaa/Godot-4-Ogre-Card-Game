extends PanelContainer
class_name QueueAnimatedPanel

@onready var artRect := $Margin/HBox/CardArt
@onready var nameLabel := $Margin/HBox/VBox/NameLabel
@onready var effectTextLabel := $Margin/HBox/VBox/EffectTextLabel

signal animationDone

func setupAndAnimate(card:Card, effect:CardAction):
	artRect.texture = card.cardArt
	nameLabel.text = card.cardName
	effectTextLabel.text = effect.customActionText
	
	var newPos := position + Vector2(0,-200)
	var tween = create_tween()
	tween.tween_property(self, "position", newPos , 2)
	$MidwayTimer.start()
	$DoneTimer.start()



func timeoutAnimationDone() -> void:
	queue_free()


func timeoutAnimationMidway() -> void:
	animationDone.emit()
