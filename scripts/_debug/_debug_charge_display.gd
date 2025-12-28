extends Label

@export var player: PlatformerCharacterController

func _physics_process(delta: float) -> void:
	if not player: return
	text = ""
	for i in range(player.ammo):
		text += "・"
