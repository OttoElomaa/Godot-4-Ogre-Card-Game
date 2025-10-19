extends Node
class_name ConditionalComponent

var passed = null

func check(card:Card, condition):
	if card:
		passed = true
	else:
		passed = false
	reset()
	
func reset():
	passed = null
