@tool
class_name PropertyPreset extends Resource

@export var target: NodePath
@export var properties: Array[StringName]

@export_storage var values: Dictionary[StringName,Variant]:
	set(value):
		values = value.duplicate(true)
