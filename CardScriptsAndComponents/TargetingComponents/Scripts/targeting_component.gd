@icon("res://Art/icons/16x16/arrow_in.png")
extends Node2D
class_name TargetingComponent


var action:Node = null
var myCard:Card = null



func setup(action:Node, card:Card):
	self.action = action
	self.myCard = card
	
