extends Node

func _enter_tree():
	get_tree().node_added.connect(_on_node_added)
	
func _on_node_added(node:Node):
	if node is Button:
		node.add_to_group('Buttons')
