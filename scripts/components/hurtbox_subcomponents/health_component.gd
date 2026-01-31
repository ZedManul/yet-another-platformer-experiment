@tool
class_name HealthComponent extends HurtBoxSubcomponent

@export_node_path("HealthTracker") var health_tracker: NodePath
@export var resistance: float = 1.0

func process(owner: HurtBox, attacker: HitBox) -> bool:
	(owner.get_node(health_tracker) as HealthTracker).hp -= attacker.damage * resistance
	return false
