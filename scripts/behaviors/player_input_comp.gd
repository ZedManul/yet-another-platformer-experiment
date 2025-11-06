@tool
class_name PlayerInputComponent extends BehaviorComponent

func update() -> void:
	cmd_direction[&"move"] = Vector2(
		Input.get_axis("move_left","move_right"),
		Input.get_axis("move_up","move_down"))
	
	if owner is Node2D:
		cmd_direction[&"aim"] = owner.get_global_mouse_position() - owner.global_position
	
	
	cmd_bool[&"jump"] = Input.is_action_pressed("jump")
	cmd_bool[&"atk"] = Input.is_action_pressed("attack")
