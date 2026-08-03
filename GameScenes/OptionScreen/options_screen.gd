extends CanvasLayer

func _ready():
	match Options.display_mode:
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			%DisplayOptions.selected = 0
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			%DisplayOptions.selected = 1
	%OptionSlider_GeneralVolume.starting_value = Options.general_volume
	%OptionSlider_MusicVolume.starting_value = Options.music_volume
	%OptionSlider_SFXVolume.starting_value = Options.sound_effect_volume

func _on_option_slider_general_volume_value_changed(new_value):
	Options.general_volume = new_value

func _on_option_slider_music_volume_value_changed(new_value):
	Options.music_volume = new_value

func _on_option_slider_sfx_volume_value_changed(new_value):
	Options.sound_effect_volume = new_value

func _on_display_options_item_selected(index):
	match index:
		0:
			Options.display_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		1:
			Options.display_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED


func _on_animation_speed_item_selected(index):
	match index:
		0:
			Options.animation_speed = 1.0
		1:
			Options.animation_speed = 2.0


func _on_confirm_pressed():
	Options.save_options()
	queue_free()
	

func _on_cancel_pressed():
	queue_free()
