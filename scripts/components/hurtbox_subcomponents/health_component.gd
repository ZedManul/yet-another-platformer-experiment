@tool
class_name HealthComponent extends HurtBoxSubcomponent

@export var max_hp: float = 10.0
var hp: float = max_hp
func process(owner: HurtBox, attacker: HitBox) -> bool:
	hp-=attacker.damage
	return false
