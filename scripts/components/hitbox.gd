class_name HitBox extends Area2D

@warning_ignore("unused_signal")
signal hit(hitbox: HitBox, hurtbox: HurtBox)


@export var enabled: bool:
	set(value):
		enabled = value
		_enable.call_deferred(enabled)


@export var damage: float = 0

@export var knockback_velocity_multiplier: float = 0.0
@export_group("Use Fixed Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var fixed_knockback: bool = false
@export var knockback: Vector2
@export_subgroup("Transform Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"")  var transform_knockback: bool = true
@export var scale_knockback: bool = false
@export_group("Use Dynamic Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var dynamic_knockback: bool = false
@export var knockback_strength: float
@export var knockback_ratio: Vector2 = Vector2.ONE
@export var knockback_origin: Node2D
@export_group("Targeting")
@export var ignored_teams: Array[HurtBox.Team]
@export var exceptions: Array[HurtBox]


func _ready() -> void:
	_enable.call_deferred(enabled)
	
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3,true)
	set_collision_mask_value(3,true)


func get_fixed_knockback() -> Vector2:
	if not fixed_knockback: return Vector2.ZERO
	
	var result: Vector2 = knockback
	
	if not transform_knockback: return result
	
	result *= (global_scale if scale_knockback 
			else global_scale.sign()
			)
	
	return result.rotated(global_rotation)

func get_dynamic_knockback(target_coords: Vector2) -> Vector2:
	if not dynamic_knockback: return Vector2.ZERO
	var kb_origin: Vector2 = global_position
	if knockback_origin: kb_origin = knockback_origin.global_position
	var result: Vector2 = (target_coords - kb_origin).normalized() * knockback_strength * knockback_ratio
	return result

func get_knockback(target_coords: Vector2) -> Vector2:
	return get_fixed_knockback() + get_dynamic_knockback(target_coords)

func _enable(value: bool) -> void:
	for i: Node in get_children():
		if not (i is CollisionShape2D or i is CollisionPolygon2D): continue
		i.disabled = not value
