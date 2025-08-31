@tool
extends Node2D

var last_rot: float

func _process(delta: float) -> void:
	if abs(last_rot - rotation_degrees) > 10:
		print_debug(" !",floor(rotation_degrees- last_rot),"! ")
	last_rot = rotation_degrees
