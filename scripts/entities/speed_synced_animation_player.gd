@tool
extends AnimationPlayer

@export var reference: AnimationPlayer

func _process(_delta: float) -> void:
	if not reference: return
	speed_scale = reference.speed_scale
