extends Node2D
class_name TravelScreen

const map_name_to_folder = {'MapAskelan': 'City', 'MapDesert': 'Desert', 'MapMoutains': 'Outcasts', 'MapJungle': 'GD'}

@export var map:Map
var event_positions_events:Dictionary[Vector2, ZoneNode] = {}

var visualsUpdateNeeded = true

@onready var PreBattleScreen: PackedScene = preload("res://GameScenes/Zone/PreBattleWindow.tscn")
var preBattleWindow:Node = null

var active_scenario_nodes:Array[ZoneNode] = []
var completed_scenarios = []

var turn = 0:
	set(value):
		turn = value
		%TurnLabel.text = str('Turn - ', turn)

## Called before _ready.
func setup(myMap: Map):
	map = myMap

func _ready():
	GameInfo.currentZone = self
	toggleUI(true)
	
	for i:Marker2D in map.markers:
		event_positions_events[i.global_position] = null
		
	SignalBus.connect('resolve_node', resolveNode)
	SceneSwitcher.connect('scene_changed', updateZoneVisuals)
	
	increment_turn()
	updateZoneVisuals()
	updateUI()
	

func process_turn():
	for i:ZoneNode in %MapNodes.get_children():
		if i.visible:
			i.process_turn()
	
	if no_elite_nodes():
		choose_scenarios_to_spawn()
	
	await updateZoneVisuals()
#	garbage_collect()

func choose_scenarios_to_spawn():
	if turn == 1 or turn % 6 == 0:
		load_scenario(Scenario.ScenarioTypes.QUEST)
	if turn % 15 == 0:
		load_scenario(Scenario.ScenarioTypes.ELITE_QUEST)
	if turn % 3 == 0:
		load_scenario(Scenario.ScenarioTypes.RANDOM_BATTLE)
	if turn % 4 == 0:
		load_scenario(Scenario.ScenarioTypes.SHOP)
	if turn % randi_range(2, 8) == 0:
		load_scenario(Scenario.ScenarioTypes.BONUS)
	
	await get_tree().process_frame
	if %MapNodes.get_children().is_empty():
		load_scenario(Scenario.ScenarioTypes.RANDOM_BATTLE)

func no_elite_nodes():
	for i:ZoneNode in %MapNodes.get_children():
		if i.elite_node == true:
			return false
	return true

func increment_turn():
	turn += 1
	process_turn()

func load_scenario(type: Scenario.ScenarioTypes):
	var possible_scenarios: Array
	
	for i in DataLoader.scenarios_by_location:
		if map_name_to_folder[map.name] == DataLoader.scenarios_by_location[i]:
			possible_scenarios.append(i)
	print('Travel screen: all scenarios for this locations: ', possible_scenarios)
	
	possible_scenarios = possible_scenarios.filter(func(i:Scenario): return i.scenario_type == type)
	print('Travel screen: filtered for correct type: ', possible_scenarios)
	
	if not type in Scenario.Repeatable:
		possible_scenarios = possible_scenarios.filter(func(i): return not completed_scenarios.has(i))
		print('Travel screen: filtered for completed: ', possible_scenarios)
	
	possible_scenarios = possible_scenarios.filter(func(i:Scenario): 
		if i.required_alliances.is_empty():
			return true
		else:
			for a in i.required_alliances:
				if not GameInfo.playerAlliances.has(a):
					return false
			return true)
	print('Travel screen: filtered for alliance conditions met: ', possible_scenarios)
	
	possible_scenarios = possible_scenarios.filter(func(i:Scenario): 
		if i.required_flags.is_empty():
			return true
		else:
			for flag in i.required_flags:
				if not GameInfo.flags.has(flag):
					return false
			return true)
	print('Travel screen: filtered for flag conditions met: ', possible_scenarios)
	
	if possible_scenarios.is_empty():
		return
	var new:Scenario = possible_scenarios.pick_random()
	place_scenario(new)

func place_scenario(new:Scenario):
	completed_scenarios.append(new)
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
		assign_node_to_marker(pos, i, new.name)
		
	MyTools.remove_child(new)

## caller is the dialogue zone node which calls this using n_name written in dialogue file
func get_node_from_same_scenario(scenario:String, n_name:String):
	for n in %MapNodes.get_children():
		if n.name == n_name:
			## Finds a node with the name n_name within the same scenario
			print('Travel Screen: node found ', n)
			return n
						
	## if everything fails, return null
	print('Travel Screen: no node found by the name ', n_name)
	return null

## Removes all scenarios with no unlocked nodes. Done every turn.
func garbage_collect():
	var active_scenarios = {}
	for node:ZoneNode in %MapNodes.get_children():
		if not active_scenario_nodes.has(node.myScenario):
			active_scenarios[node.myScenario] = []
	
		active_scenarios[node.myScenario].append(node)
	
	var keys_to_delete = []
	for key in active_scenarios:
		var deletion_needed = true
		for node:ZoneNode in active_scenarios[key]:
			if node.visible == true:
				deletion_needed = false
				break
		if deletion_needed:
			keys_to_delete.append(key)
	
	for i in keys_to_delete:
		for node:ZoneNode in active_scenarios[i]:
			print('Garbage collected node: ', node)
			node.queue_free()
		
			

func toggleUI(on:bool):
	if preBattleWindow:
		return
	
	%UI.visible = on

func updateUI():
	toggleUI(true)
	%ChampContainer.insert_champion(GameInfo.current_champion)
	%GloryAmountLabel.text = str(GameInfo.playerGlory)
	%ZoneNameLabel.text = map.map_name

func updateZoneVisuals():
	
	if not is_inside_tree():
		return
	
	toggleUI(true)
	
	await get_tree().process_frame
	
	for zoneNode:ZoneNode in %MapNodes.get_children():
		zoneNode.input_active = false
	
	for zoneNode:ZoneNode in %MapNodes.get_children():
		if zoneNode.unlocked:
			if not zoneNode.visible:
				zoneNode.show()
				await zoneNode.AnimateUnlock()
		if zoneNode.resolved:
			await zoneNode.AnimateResolve()
			zoneNode.queue_free()
			
	for zoneNode:ZoneNode in %MapNodes.get_children():
		zoneNode.input_active = true
	

			

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
		await get_tree().process_frame
		toggleUI(true)
		

func assign_node_to_marker(coords: Vector2, node:ZoneNode, scenario:String):
	var new = node.duplicate()
	%MapNodes.add_child(new)

	if event_positions_events.has(coords):
		event_positions_events[coords] = node
		new.global_position = coords

	new.setup(self, scenario)
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

func _on_node_entered(node:Map_Node):
	print('node entered')
	$AnimationPlayer.play('zoom_in')
	await $AnimationPlayer.animation_finished
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/Zone/Zone.tscn")


func _on_exit_button_pressed():
	get_tree().quit()

func _on_view_deck_button_down():
	MyTools.openDeckEdit()
