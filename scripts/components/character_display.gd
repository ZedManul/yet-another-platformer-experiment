extends Node2D

@export var player_node: PlatformerCharacterController
@export var anim_tree: AnimationTree
@export var ik_target_root: Node2D
@export var run_to_idle_rate: float = 2.0
@export var idle_to_run_rate: float = 8.0
@export var land_to_idle_rate: float = 3.0


func _process(delta: float) -> void:
	
	var velocity_ratio_x : float = clamp(player_node.velocity.x / player_node.run_speed * player_node.orient, -1, 1)
	var velocity_ratio_y : float = clamp(player_node.velocity.y / player_node.jump_impulse, -1, 1)
	var behavior := player_node.behavior
	
	anim_tree["parameters/blend_run/blend_position"] = velocity_ratio_x
	anim_tree["parameters/blend_idle/blend_position"] = velocity_ratio_x
	anim_tree["parameters/blend_air/blend_position"] = velocity_ratio_y
	
	anim_tree["parameters/blend_landing/blend_amount"] = move_toward(
			anim_tree["parameters/blend_landing/blend_amount"],
			0.0,
			land_to_idle_rate * (1.0 + abs(velocity_ratio_x))/2 * delta
		)
	
	if player_node.is_on_floor():
		if anim_tree["parameters/transition_airstate/current_state"] == "air":
			anim_tree["parameters/blend_landing/blend_amount"] = 1.0
		anim_tree["parameters/transition_airstate/transition_request"] = "ground"
	else:
		anim_tree["parameters/transition_airstate/transition_request"] = "air"
		anim_tree["parameters/blend_landing/blend_amount"] = 0.0
	
	if behavior.cmd_direction[&"move"].x == 0:
		anim_tree["parameters/blend_grounded/blend_amount"] = move_toward(
			anim_tree["parameters/blend_grounded/blend_amount"],
			0.0,
			run_to_idle_rate * delta
		)
	else:
		anim_tree["parameters/blend_grounded/blend_amount"] = move_toward(
			anim_tree["parameters/blend_grounded/blend_amount"],
			1.0,
			idle_to_run_rate * delta
		)
	
	
	
