@tool
class_name BehaviorComponent extends Resource

var owner: Node

var cmd_direction: Dictionary[StringName, Vector2] = {
	&"move" : Vector2.ZERO,
	&"aim" : Vector2.ZERO,
}

var cmd_bool: Dictionary [StringName, bool] = {
	&"atk" : false,
	&"atk_2" : false,
	&"atk_3" : false,
	&"jump" : false,
	&"dash" : false
}

var cmd_float: Dictionary [StringName, float]


var prev_cmd_direction: Dictionary = cmd_direction.duplicate(true)
var prev_cmd_bool: Dictionary = cmd_bool.duplicate(true)
var prev_cmd_float: Dictionary = cmd_float.duplicate(true)


func _init() -> void:
	resource_local_to_scene = true


func update() -> void:
	pass


func calc_prev() -> void:
	prev_cmd_direction = cmd_direction.duplicate(true)
	prev_cmd_bool = cmd_bool.duplicate(true)
	prev_cmd_float = cmd_float.duplicate(true)
