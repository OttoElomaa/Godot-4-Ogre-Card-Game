extends CustomWindow

func _physics_process(delta):
	var subtypeString = ''
	if not main:
		return
	
	if main.custom_values.has('subTypes'):
		var array: Array = main.custom_values['subTypes'] 
		for i in array:
			if not array.find(i) == 0:
				subtypeString += ' '
			subtypeString += i
			
		
	else:
		subtypeString = 'None'
	%SubtypeLabel.text = str('Aligned:[br]', subtypeString)
