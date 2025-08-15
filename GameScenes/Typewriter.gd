extends PanelContainer

var visible_characters = 0
var current_character = ''
@onready var label:RichTextLabel = $MarginContainer/RichTextLabel
var silent = [' ', ',', ':', '.']

func _ready():
	visible_characters = 0
	$AnimationPlayer.play("Typewriter")

func _physics_process(delta: float) -> void:
	if label.visible_characters != visible_characters:
		current_character = label.text[label.visible_characters]
		#print(current_character)
		if not current_character in silent:
			$AudioStreamPlayer.play()
			
		visible_characters = label.visible_characters
