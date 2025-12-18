@tool
class_name PlayerInputComponent extends BehaviorComponent

@export_node_path("Node2D") var aim_pivot: NodePath

func update() -> void:
	cmd_direction[&"move"] = Vector2(
		Input.get_axis("move_left","move_right"),
		Input.get_axis("move_up","move_down"))
	
	if owner.get_node(aim_pivot) is Node2D:
		cmd_direction[&"aim"] = owner.get_global_mouse_position() - owner.get_node(aim_pivot).global_position
	
	
	cmd_bool[&"jump"] = Input.is_action_pressed("jump")
	cmd_bool[&"dash"] = Input.is_action_pressed("dash")
	cmd_bool[&"atk"] = Input.is_action_pressed("attack")
	cmd_bool[&"atk_2"] = Input.is_action_pressed("attack_2")
	cmd_bool[&"atk_3"] = Input.is_action_pressed("attack_3")
