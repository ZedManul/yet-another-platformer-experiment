class_name FiniteStateMachine extends Node

@export var initial_state : State
var current_state : State

func _ready() -> void:
	transition(initial_state)


func _process(delta: float) -> void:
	if not current_state: return
	current_state.process(delta)


func _physics_process(delta: float) -> void:
	if not current_state: return
	current_state.physics_process(delta)


func transition(to: State) -> void:
	if not to: return
	if current_state:
		current_state.exit()
	current_state = to
	current_state.enter()
