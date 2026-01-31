class_name HitboxBeamShape extends CollisionShape2D

@export var raycast: RayCast2D

func _ready() -> void:
	shape = shape.duplicate(true)

func _physics_process(_delta: float) -> void:
	if not raycast: return
	var cast_start: Vector2 = raycast.global_position
	var cast_end: Vector2 = raycast.to_global(raycast.target_position)
	if raycast.is_colliding():
		cast_end = raycast.get_collision_point()	
	var calc_origin: Vector2 = (cast_start + cast_end)/2
	var calc_rotation: float = cast_start.angle_to_point(cast_end)
	var calc_length: float = (cast_start - cast_end).length()
	if shape is CapsuleShape2D:
		global_position = calc_origin
		global_rotation = calc_rotation+PI/2.0
		
		(shape as CapsuleShape2D).height = calc_length +(shape as CapsuleShape2D).radius * 2.0
