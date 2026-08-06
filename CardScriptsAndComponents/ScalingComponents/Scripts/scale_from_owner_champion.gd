extends ScalingComponent

enum ChampionStats {Health, Mana, Level}

@export var stat_to_use = ChampionStats.Health

func get_scaling(_args: Dictionary) -> int:
	var myCard: Card = _args['user']
	var referred_stat:int = 0
	
	match stat_to_use:
		ChampionStats.Health:
			if myCard.isEnemyCard:
				referred_stat = GameInfo.enemyHealth
			else:
				referred_stat = GameInfo.playerHealth
		ChampionStats.Mana:
			if myCard.isEnemyCard:
				referred_stat = GameInfo.enemyMana
			else:
				referred_stat = GameInfo.playerMana
		ChampionStats.Level:
			if myCard.isEnemyCard:
				referred_stat = GameInfo.enemyChampion.level
			else:
				referred_stat = GameInfo.current_champion.level
				
	return referred_stat
	
