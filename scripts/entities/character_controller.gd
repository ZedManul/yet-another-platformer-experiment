class_name PlatformerCharacterController extends CharacterBody2D


@export var team: HurtBox.Team

@export_group("Movement")
@export_subgroup("Run")
@export var run_speed: float
@export var accel_time: float:
	set(value):
		accel_time = value
		accel = run_speed/accel_time
@export var decel_time: float:
	set(value):
		decel_time = value
		decel = run_speed/decel_time
@export var air_accel_efficiency: float = 0.5
@export var air_decel_efficiency: float = 0.1

@export_subgroup("Gravity")
@export var gravity: float
@export var fall_boost: float = 1.0
@export var slam_speed: float = 700

@export_subgroup("Jump")
@export var jump_height: float:
	set(value):
		jump_height = value
		jump_impulse = sqrt(2.0 * gravity * jump_height)
@export var coyote_time: float
@export var jump_buffer: float

@export_subgroup("Dash")
@export var dash_speed: float = 600.0
@export var dash_cooldown: float = 0.5


@export_subgroup("Direction")
@export_range(0.0, 90.0, 5.0, "radians_as_degrees") var flip_buffer_angle: float = 0.0

@export_group("Combat")
@export var hurtbox: HurtBox
@export var attack_cooldown: float
@export var attack_buffer: float
@export var aim_pivot: Node2D

@export_subgroup("Slash")
@export var attack_length: float
@export var attack_recoil: float
@export var grounded_recoil_coeff: Vector2 = Vector2(0.5,0.1)
@export var atk_hitbox: HitBox
#@export var atk_visual: Node2D


@export_subgroup("Grenade")
@export var max_ammo: int = 3
@export var grenade_scene: PackedScene
@export var grenade_origin: Node2D
@export var grenade_velocity: Vector2
@export var grenade_velocity_directed: float
@export var grenade_pogo_recoil: float = 400.0

var aim_data: Vector2

var coyote_time_left: float
var jump_buffer_left: float
var attack_time_left: float
var attack_cooldown_left: float
var attack_buffer_left: float
var shot_buffer_left: float
var dash_cooldown_left: float

var can_cap_jump: bool = false
var jump_impulse: float
var decel: float
var accel: float
var orient: float = 1.0
var dash_orient: float
var ammo: int = max_ammo

func _ready() -> void:
	atk_hitbox.hit.connect(_on_attack_hit)
	hurtbox.hurt.connect(_on_hurt)
	
	hurtbox.team = team
	atk_hitbox.ignored_teams.clear()
	atk_hitbox.ignored_teams.append(team)


func _physics_process(delta: float) -> void:
	_process_aim()
	_process_timers(delta)
	_process_flip() 
	_process_gravity(delta)
	_process_run(delta)
	_process_jump()
	_process_slash()
	_process_grenade()
	_process_dash()
	move_and_slide()
	


func _process_timers(delta) -> void:
	coyote_time_left = move_toward(coyote_time_left, 0, delta)
	jump_buffer_left = move_toward(jump_buffer_left, 0, delta)
	attack_time_left = move_toward(attack_time_left, 0, delta)
	attack_cooldown_left = move_toward(attack_cooldown_left, 0, delta)
	dash_cooldown_left = move_toward(dash_cooldown_left, 0, delta)
	attack_buffer_left = move_toward(attack_buffer_left, 0, delta)
	shot_buffer_left = move_toward(shot_buffer_left, 0, delta)



func _process_gravity(delta) -> void:
	var slam_just_pressed: bool = Input.is_action_just_pressed("move_down")
	if slam_just_pressed and velocity.y < slam_speed and not is_on_floor():
		velocity.y = slam_speed
	if velocity.y<0:
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * fall_boost * delta


func _process_run(delta) -> void:
	var run_dir: float = Input.get_axis("move_left","move_right")
	var accel_coeff: float = 1.0 if is_on_floor() else air_accel_efficiency
	var friction_coeff: float = 1.0 if is_on_floor() else air_decel_efficiency
	var target_speed: float = run_speed * run_dir
	
	if sign(target_speed) != sign(velocity.x) or abs(velocity.x) > abs(target_speed):
		velocity.x = move_toward(velocity.x, 0.0, decel * friction_coeff * delta)
	if sign(target_speed) != sign(velocity.x) or abs(velocity.x) < abs(target_speed):
		velocity.x = move_toward(velocity.x, target_speed, accel * abs(run_dir) * accel_coeff * delta)


func _process_flip() -> void:
	var aim_dir: float = wrap(aim_data.angle() + PI/2, -PI, PI) * orient
	if aim_dir > -flip_buffer_angle or aim_dir < (flip_buffer_angle - PI): return
	scale.x *= -1.0
	orient *= -1.0


func _process_jump() -> void:
	
	if is_on_floor(): coyote_time_left = coyote_time
	if Input.is_action_just_pressed("jump"): jump_buffer_left = jump_buffer
	
	if coyote_time_left > 0 and jump_buffer_left > 0:
		velocity.y = -jump_impulse
		coyote_time_left = 0.0
		jump_buffer_left = 0.0
		can_cap_jump = true
	
	if velocity.y<0.0 and Input.is_action_just_released("jump") and can_cap_jump: 
		velocity.y/=2.0;
		can_cap_jump = false


func _process_aim():
	aim_data = get_global_mouse_position() - aim_pivot.global_position
	if attack_time_left>0: return
	aim_pivot.global_rotation = aim_data.angle()


func _process_slash()-> void:
	if Input.is_action_just_pressed("attack"):
		attack_buffer_left = attack_buffer
	
	if attack_time_left > 0:
		return
	
	#atk_visual.hide()
	atk_hitbox.enabled = false
	
	if attack_cooldown_left > 0 or not attack_buffer_left: return
	
	#atk_visual.show()
	atk_hitbox.enabled = true
	attack_buffer_left = 0.0
	attack_cooldown_left = attack_cooldown
	attack_time_left = attack_length



func _process_grenade() -> void:
	if not (Input.is_action_just_pressed("attack_2")): return
	if ammo <= 0: return
	ammo -=1
	var grenade_instance: ComboGrenade = grenade_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(grenade_instance)
	grenade_instance.global_position = grenade_origin.global_position
	grenade_instance.velocity = velocity + grenade_velocity * Vector2(orient, 1.0) \
			+ Vector2.from_angle(aim_pivot.global_rotation) * grenade_velocity_directed
	grenade_instance.exceptions.append(hurtbox)
	


func _process_dash() -> void:
	if dash_cooldown_left > 0 or !Input.is_action_just_pressed("dash"): return
	
	dash_orient = sign(sign(Input.get_axis("move_left","move_right")) + 0.5 * orient)
	velocity.x = dash_orient * dash_speed
	velocity.y = minf(velocity.y, 0.0)
	dash_cooldown_left = dash_cooldown




func _on_attack_hit(_hitbox: HitBox, atkd_hurtbox: HurtBox) -> void:
	
	var recoil: Vector2 = -Vector2.from_angle(aim_pivot.global_rotation)  
	if atkd_hurtbox is ComboGrenade:
		recoil *= grenade_pogo_recoil
	else:
		recoil *= attack_recoil
	if atkd_hurtbox.can_generate_resource:
		ammo = min(ammo + 1, max_ammo)
	if is_on_floor(): recoil *= grounded_recoil_coeff
	velocity = recoil
	can_cap_jump = false

func _on_hurt(_hitbox: HitBox, _hurtbox: HurtBox) -> void:
	can_cap_jump = false
