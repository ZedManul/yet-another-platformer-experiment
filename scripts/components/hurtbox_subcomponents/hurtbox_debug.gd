@tool
class_name HurtboxDebug extends HurtBoxSubcomponent


func process(owner: HurtBox, damage_data: DamageData) -> bool:
	print("Owie!, from: ", owner)
	return false
