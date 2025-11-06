class_name HitBox extends Area2D

signal on_hit(hitbox: HitBox, hurtbox: HurtBox)

@export var damage_data: DamageData

func _ready() -> void:
	monitoring = false

func _physics_process(delta: float) -> void:
	if not damage_data: return
	damage_data.scale = global_scale
	damage_data.rotation = global_rotation

func enable() -> void:
	monitorable = true

func disable() -> void:
	monitorable = false
