@tool 
extends CanvasItem

func _set(property: StringName, value: Variant) -> bool:
	if property == &"self_modulate":
		self_modulate = value
		set_instance_shader_parameter(&"modulate",self_modulate)
		return true
	return false
