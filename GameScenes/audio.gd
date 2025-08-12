extends Node2D
class_name Audio

@export var BGM = AudioStreamOggVorbis

func _ready():
	$AudioStreamPlayer.stream = BGM
	$AudioStreamPlayer.play()
