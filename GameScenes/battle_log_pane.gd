extends MarginContainer



var LogMessage = load("res://GameScenes/BasicLogMessage.tscn")

@onready var scroller := $Panel/Margin/Scroll
@onready var rows := $Panel/Margin/Scroll/Rows

func addMessage(text:String, color:Color) -> void:
	
	var message = LogMessage.instantiate()
	message.text = text
	message.color = color
	addItem(message)
	
	
func addItem(item:Node):
	
	rows.add_child(item)
	await get_tree().process_frame
	scroller.scroll_vertical = scroller.get_v_scroll_bar().max_value
