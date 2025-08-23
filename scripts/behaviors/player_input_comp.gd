@tool
class_name PlayerInputComponent extends BehaviorComponent

func update() -> void:
	cmd_direction[&"move"] = Vector2(
		Input.get_axis("move_left","move_right"),
		Input.get_axis("move_up","move_down"))
	
	cmd_bool[&"jump"] = Input.is_action_pressed("jump")
