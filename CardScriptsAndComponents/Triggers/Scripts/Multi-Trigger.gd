extends Trigger
class_name MultiTrigger

func _ready():
	var signal_array = triggered_when.split(',')
	for i in signal_array:
		if not SignalBus.is_connected(i, execute):
			SignalBus.connect(i, execute)
