@tool
class_name HealthComponent extends HurtBoxSubcomponent

@export var max_hp: float = 10.0
var hp: float = max_hp
func process(owner: HurtBox, damage_data: DamageData) -> bool:
	hp-=damage_data.damage
	return false
