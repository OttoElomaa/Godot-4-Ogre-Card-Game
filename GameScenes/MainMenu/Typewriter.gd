extends PanelContainer

var visible_characters = 0
var current_character = ''
@onready var label:RichTextLabel = $MarginContainer/RichTextLabel
var silent = [' ', ',', ':', '.']

@export_multiline var text = ""
@export var sound_off = false
@export var delay = 0.3
@export_range(1, 3.0) var delay_variance

func start():
	$MarginContainer/RichTextLabel.text = text
	visible_characters = 0
	if not text:
		return

	for i in range(len(label.text) + 1):
		label.visible_characters += 1
		current_character = label.text[label.visible_characters - 1]
		if not current_character in silent:
			if not sound_off:
				$AudioStreamPlayer.play()
		await $Timer.timeout
		$Timer.wait_time = delay * randf_range(1, delay_variance)
