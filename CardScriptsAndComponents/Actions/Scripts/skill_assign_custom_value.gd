@tool
extends Skill

## Needs a Scaling/Returning Component. Assigns a custom value retuned by it under 'value_name' in the user's custom_values variable.

@export var value_name:String

func _ready():
	child_order_changed.connect(update_configuration_warnings)

func _get_configuration_warnings():
	var warnings = PackedStringArray()
	var has_scaler = false
	
	for child in get_children():
		
		if child is ScalingComponent or child is ReturningComponent:
			has_scaler = true
	
	if not has_scaler:
		warnings.append('Needs a Scaling/Returning component child')
	
	return warnings

func activate(targets:Array) -> bool:
	var value = null
	
	if isScaled():
		value = get_scaling({'targets': targets, 'saved_targets': action.get_saved_targets()})
		value = get_return_value({'targets': targets, 'saved_targets': action.get_saved_targets()})
	
	if value is Dictionary:
		myCard.custom_values.assign(value)
	else:
		myCard.custom_values[value_name] = value
	return true
			
