extends Node2D

const settings_directory = "user://settings.ini"

@export var general_volume:= 1.0:
	set(value):
		general_volume = value
		AudioServer.set_bus_volume_linear(0, general_volume)
@export var music_volume:= 1.0:
	set(value):
		music_volume = value
		AudioServer.set_bus_volume_linear(1, music_volume)
@export var sound_effect_volume:= 1.0:
	set(value):
		sound_effect_volume = value
		AudioServer.set_bus_volume_linear(2, sound_effect_volume)

@export var display_mode = Window.MODE_WINDOWED:
	set(value):
		display_mode = value
		DisplayServer.window_set_mode(display_mode)

enum AnimationSpeeds {NORMAL, FAST, TURBO}
var animation_speed := AnimationSpeeds.NORMAL:
	set(value):
		animation_speed = value
		match animation_speed:
			AnimationSpeeds.NORMAL:
				Engine.time_scale = 1.0
			AnimationSpeeds.FAST:
				Engine.time_scale = 2.0
			AnimationSpeeds.TURBO:
				Engine.time_scale = 4.0

enum TextSpeeds {NORMAL, FAST, INSTANT}
var text_speed := TextSpeeds.NORMAL


func save_options():
	var config = ConfigFile.new()
	
	config.set_value('audio', 'general volume', general_volume)
	config.set_value('audio', 'music volume', music_volume)
	config.set_value('audio', 'sound effect volume', sound_effect_volume)
	
	config.set_value('video', 'display mode', display_mode)
	
	config.set_value('gameplay', 'animation_speed', animation_speed)
	config.set_value('gameplay', 'text_speed', text_speed)
	print(config.save(settings_directory))
	
func load_options():
	var config = ConfigFile.new()
	
	var err = config.load(settings_directory)

	if err != Error.OK:
		print('Settings: Loading error')
		return
	
	general_volume = config.get_value('audio', 'general volume', general_volume)
	music_volume = config.get_value('audio', 'music volume', music_volume)
	sound_effect_volume = config.get_value('audio', 'sound effect volume', sound_effect_volume)
	
	display_mode = config.get_value('video', 'display mode', display_mode)
	
	animation_speed = config.get_value('gameplay', 'animation_speed', animation_speed)
	animation_speed = config.get_value('gameplay', 'text_speed', text_speed)
