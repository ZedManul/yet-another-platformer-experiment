extends Node2D

@export var player_node: PlatformerCharacterController
@export var anim_tree: AnimationTree


func _process(delta: float) -> void:
	
	var velocity_ratio : float = clamp(abs(player_node.velocity.x / player_node.run_speed), 0, 1)
	var behavior := player_node.behavior
	var grounded := player_node.is_on_floor()
	
	anim_tree["parameters/blend_run/blend_amount"] = velocity_ratio
