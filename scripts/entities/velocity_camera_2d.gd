class_name VelocityCamera2D extends Camera2D

@export var target: Node2D
@export var velocity_multiplier: Vector2 = Vector2.ONE

var pos_offset: Vector2

func _ready() -> void:
	pos_offset = position

func _physics_process(delta: float) -> void:
	if !target: return
	
	global_position = target.global_position + pos_offset + target.velocity * velocity_multiplier
