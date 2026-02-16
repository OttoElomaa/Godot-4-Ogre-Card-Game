extends Node2D



func _ready() -> void:
	$CopyingHBox.hide()


func updateVisual(currentMana:int, income:int):
	#### PLAYER MANA VISUALS
	for icon in $ManaHBox.get_children():
		icon.queue_free()   #### CLEAR OLD ONES
	
	#### COPY FULL OR DEPLETED GEM TEXTURE	
	var iconToCopy:TextureRect = null
	for i in range(15):
		
		#### PLAYER HAS THIS MUCH MANA
		if (i+1) <= currentMana:
			if (i+1) <= income:  #### BASIC MANA
				iconToCopy = $CopyingHBox/BlueGem
			else:  #### ABOVE MAX MANA, SHOW EXTRA MANA - GREEN
				iconToCopy = $CopyingHBox/GreenGem
				
		#### PLAYER HAS NO MORE MANA TO SHOW
		else:
			if (i+1) <= income:  #### SHOW DEPLETED MANA MANA
				iconToCopy = $CopyingHBox/DepletedGem
			else:   #### ABOVE MAX MANA, SHOW NOTHING
				iconToCopy = null
		
		if iconToCopy:
			var newIcon = iconToCopy.duplicate()
			$ManaHBox.add_child(newIcon)
			newIcon.show()
