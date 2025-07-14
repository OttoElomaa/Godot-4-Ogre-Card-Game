extends Node






func hasDuelist() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasDuelist:
			return true
	return false


func hasShadow() -> bool:
	for keyword in $MyKeywords.get_children():
		if keyword.hasShadow:
			return true
	return false
