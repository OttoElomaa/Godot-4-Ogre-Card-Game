extends Node2D

var saved_streams:Dictionary[AudioStream, float] = {}

func play(stream:AudioStream):
	if $AudioStreamPlayer.stream == stream:
		return
	if $AudioStreamPlayer.playing:
		await fade_out(1.0)
		if not stream in saved_streams:
			saved_streams[$AudioStreamPlayer.stream] = $AudioStreamPlayer.get_playback_position()
	$AudioStreamPlayer.stream = stream
	if stream in saved_streams:
		$AudioStreamPlayer.play(saved_streams[stream])
	else:
		$AudioStreamPlayer.play()
	fade_in(1.0)

func fade_out(time:float):
	var tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, 'volume_linear', 0.0, time)
	await tween.finished

func fade_in(time:float):
	var tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, 'volume_linear', 1.0, time)
	await tween.finished
