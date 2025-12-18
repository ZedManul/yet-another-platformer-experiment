extends Polygon2D

@export var character: PlatformerCharacterController


func _physics_process(delta: float) -> void:
	if not character: return
	if character.dash_cooldown_left>0: hide()
	else: show()
