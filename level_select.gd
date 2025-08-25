extends Node2D
class_name Level_Select

signal node_clicked(node:Map_Node)
signal node_entered(node:Map_Node)
signal node_captured()

@onready var Nodes = $Nodes

var map_nodes = {'base': preload("res://Scenes/map_node.tscn")}
var node_types = ['base']
var rarities = {'base': 1.0}
var path_line = preload("res://Scenes/path_line.tscn")

#Random level generation settings:
var length = 10
var bredth = 5
var distance = 60
var max_bredth = 500
#Set to true if you want to randomly generate the map:
@export var create_level = false

@export var movement_speed = 50.0
var character_position: Node2D
var controllable = true

func _ready():
	create_lines()
	set_camera_limit()
	place_character()
	character_position = get_node_in_index(character_position)
	self.node_clicked.connect(_on_node_clicked)
	self.node_entered.connect(_on_node_entered)
	self.node_captured.connect(_on_node_captured)
	$Character.movement_speed = movement_speed
	
func _process(delta):
	if controllable:
		if Input.is_action_just_released('ui_right'):
			move_character(character_position.index + character_position.connections['right'])
		if Input.is_action_just_released('ui_left'):
			move_character(character_position.index + character_position.connections['left'])
		if Input.is_action_just_released('ui_down'):
			move_character(character_position.index + character_position.connections['down'])
		if Input.is_action_just_released('ui_up'):
			move_character(character_position.index + character_position.connections['up'])
		if Input.is_action_just_released('zoom +'):
			scale *= 0.9
		if Input.is_action_just_released('zoom -'):
			scale *= 1.1
		if Input.is_action_just_released('ui_text_delete'):
			for child in $Nodes.get_children():
				$Nodes.remove_child(child)
			for child in $Lines.get_children():
				$Lines.remove_child(child)
			create_nodes()
			character_position = $Nodes.get_children()[0]
			place_character()
			create_lines()

func _on_node_clicked(node:Map_Node):
	print(node.index)
	move_character(node.index)

func _on_node_entered(node:Map_Node):
#Runs whenever any node is entered. Contains procedures to run depending on node type.
	pass

func move_character(dir: Vector2):
	if check_for_node_in_index(dir):
		$Character/NavigationAgent2D.target_position = get_node_in_index(dir).global_position
		controllable = false
		await $Character/NavigationAgent2D.navigation_finished
		character_position = get_node_in_index(dir)
		node_entered.emit(character_position)
		place_character()
		controllable = true
	else:
		print('no such node')

func create_nodes():
#Random level generation happens here.
	print(range(length))
	for i in range(length):
		var new_pos_x = starting_position.x + (i * distance)
		var branches = randi_range(1, bredth)
		for b in range(branches):
			var node = random_node().instantiate()
			if i == 0 and b == 0:
				node = map_nodes['captured'].instantiate()
			var new_pos_y = starting_position.y + (max_bredth/2) - ((max_bredth/(bredth + 1)) * b)
			node.difficulty = i
			node.position.x = randi_range(new_pos_x + 10, new_pos_x - 10)
			node.position.y = randi_range(new_pos_y - 30, new_pos_y + 30)
			node.index = Vector2(i, b)
			$Nodes.add_child(node)

func random_node() -> PackedScene:
	var rolls: Array
	for i in map_nodes:
		rolls.append(randf() * rarities[i])
	var high_roll = rolls.find(rolls.max())
	return map_nodes[node_types[high_roll]]

#Creates lines between the nodes based on their connections.
func create_lines():
	for node in $Nodes.get_children():
		for i in node.connections:
			var line = path_line.instantiate()
			var value = node.connections[i]
			if check_for_node_in_index(node.index + value):
				line.points = PackedVector2Array([node.position, get_node_in_index(node.index + value).position])
			$Lines.add_child(line)

#Puts the Map_Character directly on top of a node in character_position.
func place_character():
	$Character.global_position = character_position.global_position

func get_node_in_index(index:Vector2):
	for child in $Nodes.get_children():
		if child.index == index:
			return child

func check_for_node_in_index(index:Vector2):
	for child in $Nodes.get_children():
		if child.index == index and child is Map_Node:
			return true
	return false

func check_if_can_move_to(node:Map_Node):
	var connections = node.connections
	for i in connections:
		if check_for_node_in_index(node.index + connections[i]):
			return true
	return false

func set_camera_limit():
	$Character/Camera2D.limit_bottom = $BackGround/Sprite2D.get_rect().end.y
	$Character/Camera2D.limit_right = $BackGround/Sprite2D.get_rect().end.x
	$Character/Camera2D.limit_left = $BackGround/Sprite2D.get_rect().position.x
	$Character/Camera2D.limit_top = $BackGround/Sprite2D.get_rect().position.y
