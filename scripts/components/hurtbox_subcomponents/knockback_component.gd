@tool
class_name KnockbackComponent extends HurtBoxSubcomponent

@export_node_path("PhysicsBody2D") var physics_body: NodePath
@export_node_path("Node2D") var knockback_center: NodePath
@export var knockback_mult: float = 1.0

func process(owner: HurtBox, attacker: HitBox) -> bool:
	var kb_center = owner.global_position
	if owner.get_node_or_null(knockback_center): kb_center = owner.get_node(knockback_center).global_position
	owner.get_node(physics_body).velocity = owner.get_node(physics_body).velocity * attacker.knockback_velocity_multiplier \
			+ attacker.get_knockback(kb_center) * knockback_mult
	return false
