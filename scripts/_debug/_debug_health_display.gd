extends Label

@export var health_tracker: HealthTracker

func _physics_process(_delta: float) -> void:
	if !health_tracker: return
	text = ""
	for i in range(health_tracker.hp):
		text += "."
