extends Node





func hasSunder() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasSunder:
			return true
	return false


func hasDuelist() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasDuelist:
			return true
	return false
