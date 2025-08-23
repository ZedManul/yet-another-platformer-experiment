class_name PlatformerCharacterController extends CharacterBody2D


@export var behavior: BehaviorComponent

@export_group("Run Parameters")
@export var run_speed: float
@export var accel: float
@export var decel: float

@export_group("Gravity Parameters")
@export var gravity: float
@export var fall_boost: float = 1.0

@export_group("Jump Parameters")
@export var jump_impulse: float
@export var coyote_time: float
@export var jump_buffer: float

var coyote_time_left: float
var jump_buffer_left: float

func _physics_process(delta: float) -> void:
	behavior.calc_prev()
	behavior.update()
	
	

func _process_timers(delta) -> void:
	coyote_time_left = move_toward(coyote_time_left, 0, delta)
	jump_buffer_left = move_toward(jump_buffer_left, 0, delta)
