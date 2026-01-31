class_name PlayerCharacterDisplay extends Node2D

const GROUNDED_BLEND_SPEED: float = 4.0
const LANDING_BLEND_FALLOFF: float = 2.0
const SWING_BLEND_FALLOFF: float = 4.0


@onready var anim_tree: AnimationTree = %AnimTree
@onready var player_controller: PlatformerCharacterController = owner

var prev_ground_state: bool = true
var prev_attack_time_left: float = 0.0

func _process(delta: float) -> void:
	var run_axis: = absf(clampf(Input.get_axis("move_left","move_right"),-1.0,1.0))
	var velocity_x_ratio: = clampf(player_controller.get_real_velocity().x/player_controller.run_speed * player_controller.orient,-1.0,1.0)
	var velocity_y_ratio: = (clampf(player_controller.get_real_velocity().y/player_controller.jump_impulse,-1.0,1.0)+1.0)/2
	var ground_state: = player_controller.is_on_floor()
	
	
	anim_tree["parameters/landing_blend/blend_amount"] = move_toward(anim_tree["parameters/landing_blend/blend_amount"], 0.0, LANDING_BLEND_FALLOFF * delta)
	#anim_tree["parameters/swing_blend/blend_amount"] = move_toward(anim_tree["parameters/swing_blend/blend_amount"], 0.0, SWING_BLEND_FALLOFF * delta)
	anim_tree["parameters/forward_blend/blend_amount"] = move_toward(anim_tree["parameters/forward_blend/blend_amount"], run_axis, GROUNDED_BLEND_SPEED * delta)
	anim_tree["parameters/backward_blend/blend_amount"] = move_toward(anim_tree["parameters/backward_blend/blend_amount"], run_axis, GROUNDED_BLEND_SPEED * delta)
	
	
	
	anim_tree["parameters/air_blend/blend_amount"] = velocity_y_ratio
	anim_tree["parameters/grounded_blend/blend_amount"] = velocity_x_ratio
	
	
	if !ground_state:
		anim_tree["parameters/air_ground_trans/transition_request"] = "Air"
	elif !prev_ground_state:
		anim_tree["parameters/air_ground_trans/transition_request"] = "Grounded"
		anim_tree["parameters/landing_blend/blend_amount"] = 1.0
	
	if player_controller.attack_time_left > 0.0 and prev_attack_time_left <= 0.0 :
		anim_tree["parameters/swing_oneshot/request"] = 1
		
	prev_attack_time_left = player_controller.attack_time_left
	prev_ground_state = ground_state
