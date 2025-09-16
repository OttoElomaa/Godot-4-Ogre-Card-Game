extends Node2D

enum TargetOptions {NONE, ALLIES, ENEMIES}

enum LocalSituations {
	NONE, ARRIVAL, CAST, BATTLE_ART, ON_TURN, RITUAL
}
enum GlobalSituations {
	NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH
	}

var myCard: Card = null
var isEnemy := false

@export var localSituation := LocalSituations.NONE
@export var globalSituation := GlobalSituations.NONE

@export var nodeKeyword := "Action type"

@export var isCost := false
@export var isPayoff := false



func setup(card:Card):	
	myCard = card
	isEnemy = card.isEnemyCard
	
	for component in get_children():
		if component.has_method("setup"):
			component.setup(self, myCard)
	


func createActionText() -> String:
	var text := ""
	
	var situationStr:String = getSituationStr()
	
	for script in get_children():
		if script.has_method("createText"):
			text += script.createText()
			text += ", "
	
	#### AT THE END, COMPILE TEXT
	text = text.rstrip(", ")
	if text != "":
		text = "%s: %s" % [situationStr, text]	
	
	return text



#### CALLED BY SITUATION MANAGER -> THAT WILL BE DONE BY SIGNALS i think?
#### CURRENTLY Called by handleRitual(), handleCast() ETC.
func activate() -> bool:
	var success := false
	
	#### TURN ON MANUAL TARGETING -> No target selected yet!
	if checkIsManualTargeting():
		handleManualTargeting()
		
	#### HANDLE AUTOMATIC TARGETING AND ACTIVATE CARD ABILITY	
	else:
		var targets:Array = getTargets()
		success = activateSkillAfterTargeting(targets)
	
	
	
		
	return success



func handleManualTargeting():
	for component:Node in get_children():
		if component.has_method("beginManualTargeting"):
			component.beginManualTargeting()



func activateSkillAfterTargeting(targets:Array) -> bool:
	var success := false
	var successfulScript:Node = null
	
	for skill:Node in get_children():
		if skill.has_method("activate"):
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
	for component:Node in get_children():
		if component.has_method("getTargets"):
			targets = component.getTargets(isEnemy)
	
	#### IF NO OTHER TARGETS WERE SELECTED, CHECK IF THERE IS AN INITIAL TARGET
	#### (ATTACK TARGET, TARGET OF PLAYED RITUAL CARD, ETC)
	if targets == []:
		if myCard.actions.initialTarget:
			targets.append(myCard.actions.initialTarget) 
			
	return targets
	




func checkIsManualTargeting() -> bool:
	for component:Node in get_children():
		if component.has_method("checkIsManualTargeting"):
			return component.checkIsManualTargeting()
	return false


func getSituationStr() -> String:
	var loc := LocalSituations
	
	match localSituation:
		
		loc.ARRIVAL:
			return "Arrival"
		loc.CAST:
			return "Cast"
		loc.BATTLE_ART:
			return "Battle Art"
		loc.ON_TURN:
			return "On Turn"
		loc.RITUAL:
			return "Ritual"
	
	return "Unknown Situation"
		


func checkIsActionTargeted() -> bool:
	for actionScript in get_children():
		if actionScript.has_method("activateTargeted"):
			return true
	return false






#### BAD CODE, REPLACE WITH SIGNALS
##########################################################

func handleArrival() -> bool:
	if localSituation == LocalSituations.ARRIVAL:
		return activate()
	return false


func handleRitual() -> bool:
	if localSituation == LocalSituations.RITUAL:
		return activate()
	return false


func handleCast() -> bool:
	var success:bool = activate()
	if success:
		myCard.restAndAnimate(true)
	
	return success



func checkHasCast() -> bool:
	if localSituation == LocalSituations.CAST:
		return true
	return false



func handleBattleArt() -> bool:
	if localSituation == LocalSituations.BATTLE_ART:
		return activate()
	return false


func handleOnTurn() -> bool:
	if localSituation == LocalSituations.ON_TURN:
		return activate()
	return false
