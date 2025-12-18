extends Line2D

@export var raycast: RayCast2D

func _physics_process(_delta: float) -> void:
	if !raycast: return
	clear_points()
	add_point(Vector2.ZERO)
	if not raycast.is_colliding():
		add_point(raycast.target_position)
		return
	
	add_point(to_local(raycast.get_collision_point()))
