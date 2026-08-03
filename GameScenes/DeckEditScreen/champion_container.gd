@tool
extends VBoxContainer

@onready var nameContainer = %NameContainer

@export var show_name = false:
	set(value):
		show_name = value
		if nameContainer:
			nameContainer.visible = show_name

var champion:Champion

func _ready():
	%NameContainer.visible = show_name

func insert_champion(champ:Champion):
	
	champion = champ
	%ChampionTexture.texture = champion.cardArt
	%ChampionName.text = champion.cardName
