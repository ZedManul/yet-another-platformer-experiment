@tool
class_name PropertyPresetGroup extends Resource

@export_storage var values: Array[PropertyPreset]:
	set(value):
		values = value.duplicate(true)
