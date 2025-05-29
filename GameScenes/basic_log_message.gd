extends PanelContainer



var text: String:
	set(val):
		$Text.text = val
	get:
		return $Text.text
		
		
var color: Color:
	set(val):
		#$Text.modulate = color
		$Text.add_theme_color_override("font_color", val)
	
