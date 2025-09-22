class_name PlatformerCharacterController extends CharacterBody2D


@export var behavior: BehaviorComponent:
	set(value):
		behavior = value
		if not behavior: return
		behavior.owner = self

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

@export_group("Direction Parameters")

@export_range(0.0, 90.0, 5.0, "radians") var flip_buffer_angle: float = 0

var coyote_time_left: float
var jump_buffer_left: float
var just_jumped: bool = false
var orient: float = 1.0

func _physics_process(delta: float) -> void:
	_process_timers(delta)
	behavior.calc_prev()
	behavior.update()
	_process_flip() 
	_process_gravity(delta)
	_process_run(delta)
	_process_jump(delta)
	move_and_slide()


func _process_timers(delta) -> void:
	coyote_time_left = move_toward(coyote_time_left, 0, delta)
	jump_buffer_left = move_toward(jump_buffer_left, 0, delta)


func _process_gravity(delta) -> void:
	if velocity.y<0:
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * fall_boost * delta


func _process_run(delta) -> void:
	var run_dir = behavior.cmd_direction[&"move"].x
	if run_dir == 0.0:
		velocity.x = move_toward(velocity.x,0.0,decel * delta)
	else:
		velocity.x = move_toward(velocity.x, run_speed * run_dir, accel * delta)
		


func _process_flip() -> void:
	var aim_dir: float = wrap(behavior.cmd_direction[&"aim"].angle() + PI/2, -PI, PI) * orient
	if aim_dir > -flip_buffer_angle or aim_dir < (flip_buffer_angle - PI): return
	scale.x *= -1.0
	orient *= -1.0


func _process_jump(delta) -> void:
	var jump_input_just_pressed = behavior.cmd_bool[&"jump"] and not behavior.prev_cmd_bool[&"jump"]
	var jump_input_just_released = not behavior.cmd_bool[&"jump"] and behavior.prev_cmd_bool[&"jump"]
	
	if is_on_floor(): coyote_time_left = coyote_time
	if jump_input_just_pressed: jump_buffer_left = jump_buffer
	
	if coyote_time_left > 0 and jump_buffer_left > 0:
		velocity.y = -jump_impulse
		coyote_time_left = 0.0
		jump_buffer_left = 0.0
		just_jumped = true
	
	if velocity.y<0.0 and jump_input_just_released: 
		velocity.y/=2.0;
	
	
