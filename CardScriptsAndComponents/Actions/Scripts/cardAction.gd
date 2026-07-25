@icon("res://Art/icons/16x16/attach.png")
extends Node2D
class_name CardAction



@export_multiline var customActionText := ""
@export_file('.wav') var action_sound
@export var particleTexture:Texture = null

var myCard: Card = null
var isEnemy := false
var hasCast := false

var targetingComponent: TargetingComponent
var animation_onTarget: AnimationActuator
var animation_onScreen: AnimationActuator
var savedTargets: Array



func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for component in get_children():
		if component.has_method("setup"):
			component.setup(self, myCard)
		if component is TargetingComponent:
			targetingComponent = component
		if component is AnimationActuator:
			match component.play_on:
				AnimationActuator.actuator_types.ON_TARGET:
					animation_onTarget = component
				AnimationActuator.actuator_types.ON_SCREEN:
					animation_onScreen = component

func setup_variant(parent:Node):
	myCard = parent
	isEnemy = parent.isEnemy
	
	for component in get_children():
		if component.has_method("setup"):
			component.setup(self, myCard)
		if component is TargetingComponent:
			targetingComponent = component

func createActionText() -> String:
	return customActionText

	

#### CALLED BY SITUATION MANAGER -> THAT WILL BE DONE BY SIGNALS i think?
#### CURRENTLY Called by handleRitual(), handleCast() ETC.
func activate(params:SignalParams) -> bool:
	var success := false
	var targets := []
	if not is_inside_tree(): #### CRASH PREVENTION?
		return success
	
	#### TURN ON MANUAL TARGETING -> No target selected yet!
	if targetingComponent is AutoTargetingComponent:
		targets = targetingComponent.getTargets()
	
	elif targetingComponent is EnemyTargetingComponent:
		if params.targetCard:
			targets.append(params.targetCard)
	
	elif targetingComponent is SourceTargetingComponent:
		if params.sourceCard:
			targets.append(params.sourceCard)
	
	elif targetingComponent is SelfTargetingComponent:
		targets.append(myCard)
	
	elif targetingComponent is ManualTargetingComponent:
		#### It is a PLAYER CARD and requires manual targeting
		if not myCard.isEnemyCard:
			var target: Card = null
			targetingComponent.activate()
			await targetingComponent.target_acquired or targetingComponent.aborted
			
			targets.append(targetingComponent.target)
			print("target acquired: ", targetingComponent.target)
			
			#### TARGET FOUND
			if targetingComponent.target:
				targets.append(targetingComponent.target)
			#### NO TARGET -> FAIL
			
		### It is an ENEMY CARD using a manual ability, refer to 
		else:
			var possible_targets = targetingComponent.getTargets()
			if possible_targets.is_empty():  #### NO TARGETS FOUND
				return success
			
			#### SORT TARGETS based on the card's AI targeting mode value.
			match myCard.targeting_mode:  
				myCard.targetingMode.WEAKEST:
					CardChecks.sort_by_weakest(possible_targets)
				myCard.targetingMode.STRONGEST:
					CardChecks.sort_by_strongest(possible_targets)
			
			targets.append(possible_targets[0])
	
	#### TARGETING COMPONENT IS NONE OF THE ABOVE
	#### -> Most likely IT DOES NOT EXIST -> That's OKAY
	else:
		pass
	
	if not targets.is_empty():
		success = await activateSkillAfterTargeting(targets)
	else:
		return success
	
	#### EFFECT ANIMATION
	if success:
		EffectAnimationQueue.queueAnimation(myCard, self, targets)
			
	return success



func get_saved_targets():
	for child in get_parent().get_children():
		if child is CardAction:
			if not child.savedTargets.is_empty():
				print(child.savedTargets)
				return child.savedTargets

func handleManualTargeting():
	for component:Node in get_children():
		if component.has_method("beginManualTargeting"):
			component.beginManualTargeting()



func activateSkillAfterTargeting(targets:Array) -> bool:
	var success := false
	if not is_inside_tree(): #### CRASH PREVENTION?
		return success
		
	var successfulScript:Node = null
	var children = get_children()

	MyTools.createCombatLogPrintout(customActionText, Color('WHITE'))
	
	for skill:Node in children:
		
		if skill is Skill:
			success = await skill.activate(targets)
			if not is_inside_tree():  #### CRASH PREVENTION?
				return success
			
			successfulScript = skill
			await get_tree().process_frame
			
			if animation_onTarget:
				for card:Card in targets:
					await animation_onTarget.activate(card)
			
	if success:
		
		if animation_onScreen:
			await animation_onScreen.activate(myCard)
		#### REST IF NEEDED
		if checkHasCast():
			myCard.restAndAnimate()
			
		
		MyTools.updateBoardCardsVisuals()
		
		
	#### CLEAR THE INITIAL TARGET AFTER ACTION USE
	if myCard.actions:
		myCard.actions.setInitialTarget(null)
	
	return success



func getTargets() -> Array:
	var targets := []
	
	#### IF ACTION HAS A TARGETING NODE  (-> IF IT HAS CUSTOM TARGETING OPTIONS)
	if targetingComponent.has_method("getTargets"):
			targets = targetingComponent.getTargets(isEnemy)
	
	#### IF NO OTHER TARGETS WERE SELECTED, CHECK IF THERE IS AN INITIAL TARGET
	#### (ATTACK TARGET, TARGET OF PLAYED RITUAL CARD, ETC)
	if targets == []:
		if myCard.actions.initialTarget:
			targets.append(myCard.actions.initialTarget) 
			
	return targets
	

func checkIsManualTargeting() -> bool:
	if targetingComponent.has_method("checkIsManualTargeting"):
		return targetingComponent.checkIsManualTargeting()
	return false


func getSituationStr() -> String:
	if get_parent() is not Node2D:
		return get_parent().situation_text
	else:
		if myCard.cardType == myCard.CardTypes.RITUAL:
			return "Ritual"
		else:
			return "Cast"


func checkIsActionTargeted() -> bool:
	for actionScript in get_children():
		if actionScript.has_method("activateTargeted"):
			return true
	return false

func checkHasCast() -> bool:
	return hasCast
