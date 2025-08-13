extends Node




func hasDuelist() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasDuelist:
			return true
	return false


func hasVanguard() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasVanguard:
			return true
	return false
