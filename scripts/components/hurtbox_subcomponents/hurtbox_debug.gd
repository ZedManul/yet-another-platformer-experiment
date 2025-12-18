@tool
class_name HurtboxDebug extends HurtBoxSubcomponent


func process(owner: HurtBox, attacker: HitBox) -> bool:
	print("Owie!, from: ", owner)
	return false
