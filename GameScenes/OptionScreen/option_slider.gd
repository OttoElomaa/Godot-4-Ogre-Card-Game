@tool
extends MarginContainer

signal value_changed(new_value:float)

@export var property_name:String = '':
	set(value):
		property_name = value
		%Prop_Name.text = property_name

var starting_value: float:
	set(value):
		starting_value = value
		%HSlider.value = starting_value
		%Percentage.text = str(int(%HSlider.value * 100), '%')

	
func _on_h_slider_value_changed(value):
	%Percentage.text = str(int(%HSlider.value * 100), '%')
	value_changed.emit(%HSlider.value)
