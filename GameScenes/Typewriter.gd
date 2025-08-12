extends Control

var visible_characters = 0
var current_character = ''
@onready var label = $RichTextLabel
var silent = [' ', ',', ':', '.']

func _ready():
	$AnimationPlayer.play("Typewriter")

func _process(delta):
	if label.visible_characters != visible_characters:
		current_character = label.text[label.visible_characters]
		if !(current_character in silent):
			$AudioStreamPlayer.play()
		else:
			pass
		visible_characters = $RichTextLabel.visible_characters
