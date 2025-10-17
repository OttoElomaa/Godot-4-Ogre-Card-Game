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

@export var isCost := false
@export var isPayoff := false



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
func activate(args) -> bool:
	var success := false
	
	#### TURN ON MANUAL TARGETING -> No target selected yet!
	if targetingComponent is AutoTargetingComponent:
		var targets:Array = targetingComponent.getTargets(myCard)
		success = activateSkillAfterTargeting(targets)
	
	elif targetingComponent is EnemyTargetingComponent:
		var targets:Array = []
		targets.append(args[1])
		success = activateSkillAfterTargeting(targets)
	
	elif targetingComponent is SelfTargetingComponent:
		var targets:Array = []
		targets.append(myCard)
		success = activateSkillAfterTargeting(targets)
	
	elif targetingComponent is ManualTargetingComponent:
		var target: Card = null
		targetingComponent.activate()
		await targetingComponent.target_acquired or targetingComponent.aborted
		print("target acquired: ", targetingComponent.target)
		if targetingComponent.target:
			var targets:Array = []
			targets.append(targetingComponent.target)
			success = activateSkillAfterTargeting(targets)
		
	else:
		var targets = []
		success = activateSkillAfterTargeting(targets)
			#return false
	
	#### HANDLE AUTOMATIC TARGETING AND ACTIVATE CARD ABILITY	
#	else:
#		var targets:Array = getTargets()
#		success = activateSkillAfterTargeting(targets)
	

	
		
	return success



func handleManualTargeting():
	for component:Node in get_children():
		if component.has_method("beginManualTargeting"):
			component.beginManualTargeting()



func activateSkillAfterTargeting(targets:Array) -> bool:
	var success := false
	var successfulScript:Node = null
	
	for skill:Node in get_children():
		if skill is Skill:
			success = skill.activate(targets)
			successfulScript = skill
			
	if success:
		#### REST IF NEEDED
		if checkHasCast():
			myCard.restAndAnimate(true)
			
		
		successfulScript.createPrintout(self)  #### CREATE COMBAT LOG ENTRY	
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
#	var loc := LocalSituations
#	
#	match localSituation:
#		
#		loc.ARRIVAL:
#			return "Arrival"
#		loc.CAST:
#			return "Cast"
#		loc.BATTLE_ART:
#			return "Battle Art"
#		loc.ON_TURN:
#			return "On Turn"
#		loc.RITUAL:
#			return "Ritual"
	
#	return "Unknown Situation"
		


func checkIsActionTargeted() -> bool:
	for actionScript in get_children():
		if actionScript.has_method("activateTargeted"):
			return true
	return false






#### BAD CODE, REPLACE WITH SIGNALS
##########################################################

#func handleArrival() -> bool:
#	if localSituation == LocalSituations.ARRIVAL:
#		return activate()
#	return false


#func handleRitual() -> bool:
#	if localSituation == LocalSituations.RITUAL:
#		return activate()
#	return false


#func handleCast() -> bool:
#	var success:bool = activate()
#	if success:
#		myCard.restAndAnimate(true)
	
#	return success


func checkHasCast() -> bool:
	return hasCast



#func handleBattleArt() -> bool:
#	if localSituation == LocalSituations.BATTLE_ART:
#		return activate()
#	return false


#func handleOnTurn() -> bool:
#	if localSituation == LocalSituations.ON_TURN:
#		return activate()
#	return false
