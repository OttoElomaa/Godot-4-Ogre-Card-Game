extends PanelContainer

var visible_characters = 0
var current_character = ''
@onready var label:RichTextLabel = $MarginContainer/RichTextLabel
var silent = [' ', ',', ':', '.']

@export_multiline var text = ""
@export var sound_off = false
@export var delay = 0.3
@export_range(0.1, 3.0) var delay_variance

func _ready():
	start()

func start():
	$MarginContainer/RichTextLabel.text = text
	$MarginContainer/RichTextLabel.visible_characters = 0
	
	if not text:
		return

	for i in range(len(label.text) + 1):
		label.visible_characters += 1
		current_character = label.text[clamp(visible_characters - 1, 0, len(label.text))]
		if not current_character in silent:
			if not sound_off:
				$AudioStreamPlayer.play()
		await $Timer.timeout
		$Timer.wait_time = delay * randf_range(1, delay_variance)
