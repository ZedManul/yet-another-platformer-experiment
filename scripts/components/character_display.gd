extends Node2D

@export var player_node: PlatformerCharacterController
@export var anim_tree: AnimationTree
@export var ik_target_root: Node2D

func _process(delta: float) -> void:
	
	var velocity_ratio : float = clamp(player_node.velocity.x / player_node.run_speed * player_node.orient, -1, 1)
	var behavior := player_node.behavior
	var grounded := player_node.is_on_floor()
	
	anim_tree["parameters/blend_run/blend_position"] = velocity_ratio
	
	
	
