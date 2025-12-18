extends HitBox

@export var duration: float = 0.1
var duration_left = duration

func _physics_process(delta: float) -> void:
	duration_left-=delta
	if duration_left<=0:
		queue_free()
