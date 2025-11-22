@icon("res://Art/icons/16x16/attach.png")
extends Node2D
class_name CardAction

enum TargetOptions {NONE, ALLIES, ENEMIES}

#enum LocalSituations {
#	NONE, ARRIVAL, CAST, BATTLE_ART, ON_TURN, RITUAL
#}
#enum GlobalSituations {
#	NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH
#	}

var myCard: Card = null
var isEnemy := false
var hasCast := false

var targetingComponent: TargetingComponent

#@export var localSituation := LocalSituations.NONE
#@export var globalSituation := GlobalSituations.NONE

#@export var nodeKeyword := "Action type"
@export_multiline var customActionText := ""
@export_file('.wav') var action_sound

#@export var isCost := false
var savedTargets: Array
#@export var isPayoff := false



func setup(card:Card):	
	myCard = card
	isEnemy = card.isEnemyCard
	
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
	
	#### TURN ON MANUAL TARGETING -> No target selected yet!
	if targetingComponent is AutoTargetingComponent:
		var targets:Array = targetingComponent.getTargets()
		success = await activateSkillAfterTargeting(targets)
	
	elif targetingComponent is EnemyTargetingComponent:
		var targets:Array = []
		targets.append(params.targetCard)
		success = await activateSkillAfterTargeting(targets)
	
	elif targetingComponent is SelfTargetingComponent:
		var targets:Array = []
		targets.append(myCard)
		success = await activateSkillAfterTargeting(targets)
	
	elif targetingComponent is ManualTargetingComponent:
		### If the player's card requires manual targeting, await its success
		if not myCard.isEnemyCard:
			var target: Card = null
			targetingComponent.activate()
			await targetingComponent.target_acquired or targetingComponent.aborted
			print("target acquired: ", targetingComponent.target)
			if targetingComponent.target:
				var targets:Array = []
				targets.append(targetingComponent.target)
				success = await activateSkillAfterTargeting(targets)
			else:
				return success
		### If an enemy targets a manual ability, refer to its AI targeting mode value.
		else:
			var possible_targets = targetingComponent.getTargets()
			match myCard.targeting_mode:
				myCard.targetingMode.WEAKEST:
					myCard.battleSystem.sort_by_weakest(possible_targets)
				myCard.targetingMode.STRONGEST:
					myCard.battleSystem.sort_by_strongest(possible_targets)
			if possible_targets.is_empty():
				return success
			else:
				var targets:Array = []
				targets.append(possible_targets[0])
				success = await activateSkillAfterTargeting(targets)
	else:
		var targets = []
		success = await activateSkillAfterTargeting(targets)
			
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
	var successfulScript:Node = null
	var children = get_children()

	MyTools.createCombatLogPrintout(customActionText, Color('WHITE'))
	
	for skill:Node in children:
		
		if skill is Skill:
			success = await skill.activate(targets)
			successfulScript = skill
			await get_tree().process_frame
			
			
	if success:
		#### REST IF NEEDED
		if checkHasCast():
			myCard.restAndAnimate()
			
		
		MyTools.updateBoardCardsVisuals()
		
		
	#### CLEAR THE INITIAL TARGET AFTER ACTION USE
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
