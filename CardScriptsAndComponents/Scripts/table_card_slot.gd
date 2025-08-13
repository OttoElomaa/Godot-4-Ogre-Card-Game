extends Node2D
class_name CardSlot


var slotType := 0
var isAvailable := true

func toggleAvailable(available: bool):
	isAvailable = available
