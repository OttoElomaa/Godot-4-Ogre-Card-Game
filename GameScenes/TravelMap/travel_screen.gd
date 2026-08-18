extends Node2D
class_name TravelScreen

const map_name_to_folder = {'MapAskelan': 'City'}

@export var map:Map
var event_positions_events:Dictionary[Vector2, ZoneNode] = {}
var visualsUpdateNeeded = true

var randomBattleNodeScene = preload("uid://cu0e7fgg0vk3s")

@onready var PreBattleScreen: PackedScene = preload("res://GameScenes/Zone/PreBattleWindow.tscn")
var preBattleWindow:Node = null

var active_scenario_nodes:Array[ZoneNode] = []
var completed_scenarios = []

var turn = 0:
	set(value):
		turn = value
		%TurnLabel.text = turn

## Called before _ready.
func setup(myMap: Map):
	map = myMap

func _ready():
	for i:Marker2D in map.markers:
		event_positions_events[i.global_position] = null
		
	SignalBus.connect('unlock_node', unlockNode)
	SignalBus.connect('resolve_node', resolveNode)
	
	updateZoneVisuals()
	updateUI()
	

func process_turn():
	for i:ZoneNode in %MapNodes.get_children():
		i.process_turn()
	load_scenario()

func increment_turn():
	turn += 1
	process_turn()

func load_scenario():
	var possible_scenarios: Array
	
	for i in DataLoader.scenarios_by_location:
		if map_name_to_folder[map.name] == DataLoader.scenarios_by_location[i]:
			possible_scenarios.append(i)
	print('Travel screen: all scenarios for this locations: ', possible_scenarios)
	possible_scenarios = possible_scenarios.filter(func(i): return not completed_scenarios.has(i))
	print('Travel screen: filtered for completed: ', possible_scenarios)
	if possible_scenarios.is_empty():
		return
	var new = possible_scenarios.pick_random()
	completed_scenarios.append(new)
	new = new.instantiate() as Scenario
	MyTools.add_child(new)
	print('Travel Screen: loaded scenario ', new.name)
	await get_tree().process_frame
	var nodes = new.get_all_nodes()
	
	## Placing the scenario to a random position.
	var new_pos: Vector2
	if new.random_position:
		
		if not new.random_locations.is_empty():
			new_pos = get_random_free_marker_in_list(new.random_locations)
		else:
			new_pos = get_random_free_marker()
	
	for i:ZoneNode in nodes:
		var pos:Vector2
		if new_pos:
			pos = new_pos
		else:
			pos = i.position
		assign_node_to_marker(pos, i)
		active_scenario_nodes.append(i)
		
	MyTools.remove_child(new)

func toggleUI(on:bool):
	%UI.visible = on

func updateUI():
	%ChampContainer.insert_champion(GameInfo.current_champion)
	%GloryAmountLabel.text = str(GameInfo.playerGlory)
	%ZoneNameLabel.text = map.map_name

func updateZoneVisuals():
	for zoneNode in GameInfo.nodesToResolve:
		zoneNode.resolve()
		
	GameInfo.nodesToResolve.clear()
	
	process_turn()

func unlockNode(zoneNodeID:String):
	for child:ZoneNode in %MapNodes.get_children():
		if child.name == zoneNodeID: 
			child.unlock()
		elif child.node_name == zoneNodeID:
			child.unlock()

func resolveNode(zoneNodeID:String):
	for child:ZoneNode in %MapNodes.get_children():
		if child.name == zoneNodeID: 
			child.resolve()

func openPrebattle(b_node:Node2D):
	print('Travel Screen: Opening Prebattle')
	toggleUI(false)
	preBattleWindow = PreBattleScreen.instantiate()
	$PreBattleCanvas.add_child(preBattleWindow)
	preBattleWindow.setup(b_node)
	
func closePrebattle():
	if preBattleWindow:
		preBattleWindow.queue_free()
		toggleUI(false)

func assign_node_to_marker(coords: Vector2, node:ZoneNode):
	var new = node.duplicate()
	%MapNodes.add_child(new)

	if event_positions_events.has(coords):
		event_positions_events[coords] = node
		new.global_position = coords

	new.setup(self)
	print('added child ', new)

func get_random_free_marker() -> Vector2:
	print('getting random free marker')
	var free_nodes:Array[Vector2] = []
	for c in event_positions_events:
		if event_positions_events[c] == null:
			free_nodes.append(c)
	var random_marker = free_nodes.pick_random()
	print('placing node at ', random_marker)
	return random_marker

func get_random_free_marker_in_list(list:Array[Vector2]) -> Vector2:
	print('getting random free marker')
	var free_nodes:Array[Vector2] = []
	for c in list:
		if event_positions_events.has(c):
			if event_positions_events[c] == null:
				free_nodes.append(c)
	var random_marker = free_nodes.pick_random()
	print('placing node at ', random_marker)
	return random_marker

func node_exists_in_coords(coords:Vector2) -> bool:
	if event_positions_events.has(coords):
		if event_positions_events[coords] != null:
			return true
	return false

func create_random_battle():
	var new = randomBattleNodeScene.instantiate() as ZoneBattleIcon
	print(new)
	assign_node_to_marker(get_random_free_marker(), new)
	new.generate_fight()

func _on_node_entered(node:Map_Node):
	print('node entered')
	$AnimationPlayer.play('zoom_in')
	await $AnimationPlayer.animation_finished
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/Zone/Zone.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
