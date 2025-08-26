@tool
class_name PropertyPresetManager extends Node

@export_tool_button("Record", "Save") var record_func: Callable = record

@export_tool_button("Apply", "Load") var apply_func: Callable = apply

@export var current_state: String:
	set(value):
		current_state = value
		if states.has(current_state): apply()
@export var states: Array[String]
@export var target_properties: Array[PropertyPreset]
@export_storage var values: Dictionary[String,PropertyPresetGroup]:
	set(value):
		values = value.duplicate(true)


func record(state := current_state) -> void:
	#print_rich("[color=slategray]recording: ", state, "[/color]")
	if not states.has(state):
		push_warning(str("State \"", state, "\" not defined!"))
		return
	for i: String in values.keys():
		if not states.has(i):
			values.erase(i)
	
	if not values.keys().has(state): values[state] = PropertyPresetGroup.new()
	values[state].values.resize(target_properties.size())
	
	for i: int in range(target_properties.size()):
		values[state].values[i] = target_properties[i].duplicate(true)
	
	for i: PropertyPreset in values[state].values:
		var target_node: Node = get_node_or_null(i.target)
		if not target_node: continue
		for j:StringName in i.properties:
			i.values[j] = target_node.get(j)

func apply(state := current_state) -> void:
	#print_rich("[color=slategray]applying: ", state, "[/color]")
	if not states.has(state): 
		push_warning(str("State \"", state, "\" not defined!"))
		return
	if not values.keys().has(state):
		push_warning("State \"", state, "\" not set!")
		return
	if not values[state]: record()
	for i: PropertyPreset in values[state].values:
		var target_node: Node = get_node_or_null(i.target)
		if not target_node: continue
		for j:StringName in i.properties:
			if target_node.get(j) == null: continue
			target_node.set(j, i.values[j])
