@tool
class_name DamageData extends Resource

@export var damage: float = 0
@export_group("Use Fixed Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var fixed_knockback: bool = false
@export var knockback: Vector2
@export_subgroup("Transform Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"")  var transform_knockback: bool = true
@export var scale_knockback: bool = false
@export_group("Use Dynamic Knockback")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var dynamic_knockback: bool = false
@export var knockback_strength: float
@export var knockback_origin: Vector2

var scale: Vector2
var rotation: float

func _init():
	resource_local_to_scene = true

func calc_fixed_knockback(owner: Node2D) -> Vector2:
	if not fixed_knockback: return Vector2.ZERO
	
	var result: Vector2
	result = knockback
	
	if not transform_knockback: return result
	
	result *= (scale if scale_knockback 
			else scale.sign()
			)
	
	return result.rotated(rotation)
