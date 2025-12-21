class_name SpellDashTarget extends HitBox

@export var tether_line: Line2D
var spell_owner: PlatformerCharacterController

func _physics_process(delta: float) -> void:
	if not spell_owner or not tether_line: return
	tether_line.clear_points()
	tether_line.add_point(Vector2.ZERO)
	tether_line.add_point(to_local(spell_owner.dash_raycast.global_position))
	
	
