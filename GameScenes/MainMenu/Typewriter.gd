extends PanelContainer

var visible_characters = 0
var current_character = ''
@onready var label:RichTextLabel = $MarginContainer/RichTextLabel
var silent = [' ', ',', ':', '.']

@export_multiline var text = ""
@export var sound_off = false
@export var delay = 0.3
@export_range(0.1, 3.0) var delay_variance
@export var ochre_shadows = false
const text_to_shadow_colors = [[Color.ANTIQUE_WHITE, Color.CHOCOLATE],
	[Color(0.269, 0.076, 0.013, 1.0), Color(0.972, 0.4, 0.205, 1.0)],
	[Color.NAVAJO_WHITE, Color(0.09, 0.029, 0.005, 1.0)],
	[Color.ANTIQUE_WHITE, Color.FIREBRICK]]

func _ready():
	start()

func start():
	$MarginContainer/RichTextLabel.text = text
	var color_scheme = text_to_shadow_colors.pick_random()
	var text_color = color_scheme[0]
	var shadow_color = color_scheme[1]
	$MarginContainer/RichTextLabel.add_theme_color_override("default_color", text_color) 
	$MarginContainer/RichTextLabel.add_theme_color_override("font_shadow_color", shadow_color) 
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
