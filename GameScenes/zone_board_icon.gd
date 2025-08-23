extends Node2D


var zone:Node = null




func setup(zone:Node):
	self.zone = zone



func mouseEnteredShowBattleInfo() -> void:
	zone.showBattleInfo(self)
