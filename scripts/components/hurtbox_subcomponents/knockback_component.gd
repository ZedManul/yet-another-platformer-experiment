@tool
class_name KnockbackComponent extends HurtBoxSubcomponent

@export_node_path("PhysicsBody2D") var physics_body: NodePath
@export var knockback_mult: float = 1.0

func process(owner: HurtBox, damage_data: DamageData) -> bool:
	
	owner.get_node(physics_body).velocity = calc_fixed_knockback(damage_data)
	return false


func calc_fixed_knockback(damage_data: DamageData) -> Vector2:
	if not damage_data.fixed_knockback: return Vector2.ZERO
	
	var knockback: Vector2
	knockback = damage_data.knockback * knockback_mult
	
	if not damage_data.transform_knockback: return knockback
	
	knockback *= (damage_data.scale if damage_data.scale_knockback 
			else damage_data.scale.sign()
			)
	
	return knockback.rotated(damage_data.rotation)
