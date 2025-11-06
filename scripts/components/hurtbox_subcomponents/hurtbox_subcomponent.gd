@abstract
@tool
class_name HurtBoxSubcomponent extends Resource

func _init():
   resource_local_to_scene = true

@abstract func process(owner: HurtBox, damage_data: DamageData) -> bool
