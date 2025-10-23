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

func collectKeywords() -> Array:
	var keywords = []
	for keyword in $MyKeywords.get_children():
		if keyword is Keyword:
			keywords.append(keyword)
	return keywords

func clearKeywords():
	for keyword:Keyword in $MyKeywords.get_children():
		queue_free()
