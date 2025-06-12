extends Node2D



var isPhased := false

var hasDoom := false




func togglePhased(isPhased:bool):
	self.isPhased = isPhased


func updatePhasedVisuals():
	if isPhased:
		$PhasedTexture.show()
	else:
		$PhasedTexture.hide()
