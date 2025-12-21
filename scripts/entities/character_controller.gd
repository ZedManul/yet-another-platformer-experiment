class_name PlatformerCharacterController extends CharacterBody2D


@export var behavior: BehaviorComponent:
	set(value):
		behavior = value
		if not behavior: return
		behavior.owner = self


@export var team: HurtBox.TEAM

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



@export_subgroup("Direction")
@export_range(0.0, 90.0, 5.0, "radians_as_degrees") var flip_buffer_angle: float = 0.0

@export_group("Combat")
@export var hurtbox: HurtBox
@export var attack_cooldown: float
@export var attack_buffer: float

@export_subgroup("Slash")
@export var attack_length: float
@export var attack_recoil: float
@export var grounded_recoil_coeff: Vector2 = Vector2(0.5,0.1)
@export var atk_hitbox: HitBox
@export var atk_visual: Node2D

@export_subgroup("Spell Resource")
@export var spell_pickup_scene: PackedScene
@export var max_spell_charges: int = 3
@export var spell_charge_pickup_radius: float = 96
@export var force_recall_time: float = 2.0

@export_subgroup("Spell Bomb")
@export var spell_bomb_scene: PackedScene
@export var spell_bomb_velocity: Vector2
@export var spell_bomb_velocity_transfer_scale: Vector2 = Vector2.ONE
@export var spell_bomb_origin: Node2D

@export_subgroup("Spell Dash")
@export var dash_target_scene: PackedScene
@export var dash_raycast: RayCast2D
@export var dash_velocity: float = 400.0
@export var dash_delay: float = 1.0
@export var dash_exit_velocity: Vector2 = Vector2(100.0,-200.0)
@export var dash_pickup_eject_velocity: float = 300



var dash_target_instance: SpellDashTarget
var coyote_time_left: float
var jump_buffer_left: float
var attack_time_left: float	
var attack_cooldown_left: float
var attack_buffer_left: float
var dash_time_left: float:
	set(value):
		dash_time_just_expired = (dash_time_left > 0 and value <= 0) or dash_time_just_expired
		dash_time_left = value
var dash_delay_left: float:
	set(value):
		dash_delay_just_expired = (dash_delay_left > 0 and value <= 0) or dash_delay_just_expired
		dash_delay_left = value

var dash_time_just_expired: bool = false
var dash_delay_just_expired: bool = false

var just_jumped: bool = false
var jump_impulse: float
var decel: float
var accel: float
var orient: float = 1.0
var dash_vector: Vector2


var spell_charges: int = max_spell_charges:
	set(value):
		spell_charges = value
		force_recall_time_left = force_recall_time
var spell_charge_pickups: Array[SpellPickup]
var force_recall_time_left = 0.0

func _ready() -> void:
	atk_hitbox.on_hit.connect(_on_attack_hit)
	hurtbox.on_hurt.connect(_on_hurt)
	
	hurtbox.team = team
	atk_hitbox.ignored_teams.clear()
	atk_hitbox.ignored_teams.append(team)


func _physics_process(delta: float) -> void:
	behavior.calc_prev()
	behavior.update()
	_process_timers(delta)
	_process_charge_pickups()
	_process_force_recall_charge_pickups() 
	_process_flip() 
	_process_gravity(delta)
	_process_run(delta)
	_process_jump()
	_process_spell_bomb()
	_process_attack()
	_process_spell_dash()
	move_and_slide()
	_update_expirations()


func _process_timers(delta) -> void:
	coyote_time_left = move_toward(coyote_time_left, 0, delta)
	jump_buffer_left = move_toward(jump_buffer_left, 0, delta)
	attack_time_left = move_toward(attack_time_left, 0, delta)
	attack_cooldown_left = move_toward(attack_cooldown_left, 0, delta)
	dash_time_left = move_toward(dash_time_left, 0, delta)
	dash_delay_left = move_toward(dash_delay_left, 0, delta)
	attack_buffer_left = move_toward(attack_buffer_left, 0, delta)
	force_recall_time_left = move_toward(force_recall_time_left, 0, delta)

func _update_expirations() -> void:
	dash_time_just_expired = false
	dash_delay_just_expired = false

func _process_gravity(delta) -> void:
	var slam_just_pressed: bool = behavior.cmd_direction[&"move"].y>0 and not behavior.prev_cmd_direction[&"move"].y>0
	if slam_just_pressed and velocity.y < slam_speed and not is_on_floor():
		velocity.y = slam_speed
	if velocity.y<0 or behavior.cmd_bool[&"jump"]:
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * fall_boost * delta


func _process_run(delta) -> void:
	var run_dir: float = behavior.cmd_direction[&"move"].x
	var accel_coeff: float = 1.0 if is_on_floor() else air_accel_efficiency
	var friction_coeff: float = 1.0 if is_on_floor() else air_decel_efficiency
	var target_speed: float = run_speed * run_dir
	
	if sign(run_dir) != sign(velocity.x) or abs(velocity.x) > abs(target_speed):
		velocity.x = move_toward(velocity.x,0.0, decel * friction_coeff * delta)
	
	velocity.x = move_toward(velocity.x, target_speed, accel * abs(run_dir) * accel_coeff * delta)


func _process_flip() -> void:
	var aim_dir: float = wrap(behavior.cmd_direction[&"aim"].angle() + PI/2, -PI, PI) * orient
	if aim_dir > -flip_buffer_angle or aim_dir < (flip_buffer_angle - PI): return
	scale.x *= -1.0
	orient *= -1.0


func _process_jump() -> void:
	var jump_input_just_pressed = behavior.cmd_bool[&"jump"] and not behavior.prev_cmd_bool[&"jump"]
	var jump_input_just_released = not behavior.cmd_bool[&"jump"] and behavior.prev_cmd_bool[&"jump"]
	
	if is_on_floor(): coyote_time_left = coyote_time
	if jump_input_just_pressed: jump_buffer_left = jump_buffer
	
	if coyote_time_left > 0 and jump_buffer_left > 0:
		velocity.y = -jump_impulse
		coyote_time_left = 0.0
		jump_buffer_left = 0.0
		just_jumped = true
		dash_time_left = 0.0
	
	if velocity.y<0.0 and jump_input_just_released: 
		velocity.y/=2.0;


func _process_attack()-> void:
	if behavior.cmd_bool[&"atk"] and not behavior.prev_cmd_bool[&"atk"]:
		attack_buffer_left = attack_buffer
	
	if attack_time_left > 0:
		return
	
	atk_visual.hide()
	atk_hitbox.enabled = false
	atk_hitbox.global_rotation = behavior.cmd_direction[&"aim"].angle()
	
	if attack_cooldown_left > 0 or not attack_buffer_left: return
	
	atk_visual.show()
	atk_hitbox.enabled = true
	
	attack_cooldown_left = attack_cooldown
	attack_time_left = attack_length


func _process_spell_bomb() -> void: 
	if spell_charges <= 0: return
	var attack_input_just_pressed = behavior.cmd_bool[&"atk_2"] and not behavior.prev_cmd_bool[&"atk_2"]
	
	if not attack_input_just_pressed: return
	
	var bomb_instance = spell_bomb_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(bomb_instance)
	bomb_instance.global_position = spell_bomb_origin.global_position
	(bomb_instance as SpellBomb).velocity = velocity * spell_bomb_velocity_transfer_scale + spell_bomb_velocity * Vector2(orient,1)
	(bomb_instance as SpellBomb).spell_owner = self
	
	spell_charges-=1
	
	if hurtbox:
		(bomb_instance as SpellBomb).exceptions.append(hurtbox)

func _process_spell_dash() -> void:
	if dash_time_just_expired:
		velocity = dash_exit_velocity * Vector2(orient, 1)
		spawn_spell_pickup(dash_target_instance.global_position, 
				-Vector2.from_angle(dash_target_instance.global_rotation) * dash_pickup_eject_velocity)
		dash_target_instance.queue_free()
		dash_target_instance = null
	if dash_time_left > 0:
		velocity = (dash_target_instance.global_position - dash_raycast.global_position).normalized() * dash_velocity
		return
	if dash_delay_just_expired:
		dash_time_left = dash_vector.length()/dash_velocity;
	if  dash_delay_left > 0:
		velocity = Vector2.ZERO
		return
	
	if spell_charges <= 0 or dash_time_left > 0: return
	if not dash_raycast: return
	var attack_input_just_pressed = behavior.cmd_bool[&"atk_3"] and not behavior.prev_cmd_bool[&"atk_3"]
	if not attack_input_just_pressed: return
	dash_raycast.global_rotation = behavior.cmd_direction[&"aim"].angle()
	dash_raycast.force_update_transform()
	dash_raycast.force_raycast_update()
	dash_delay_left = dash_delay
	spell_charges -= 1
	if dash_raycast.is_colliding():
		dash_vector = dash_raycast.get_collision_point() - dash_raycast.global_position
	else:
		dash_vector = dash_raycast.to_global(dash_raycast.target_position) - dash_raycast.global_position
	dash_target_instance = dash_target_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(dash_target_instance)
	dash_target_instance.global_position = dash_raycast.global_position + dash_vector
	dash_target_instance.global_rotation = dash_raycast.global_rotation
	dash_target_instance.spell_owner = self

func _process_charge_pickups() -> void:
	var picked_up: Array[SpellPickup]
	for p: SpellPickup in spell_charge_pickups:
		if p.activation_delay_left>0: continue
		if global_position.distance_squared_to(p.global_position) > spell_charge_pickup_radius * spell_charge_pickup_radius: continue
		picked_up.append(p)
	
	for p: SpellPickup in picked_up:
		spell_charges+=1
		spell_charge_pickups.erase(p)
		p.queue_free()


func _process_force_recall_charge_pickups() -> void:
	if not (behavior.cmd_direction[&"move"].y > 0 and velocity.is_zero_approx()): 
		force_recall_time_left = force_recall_time
	
	if force_recall_time_left > 0: return
	
	for p in spell_charge_pickups:
		if p: p.queue_free()
	spell_charge_pickups.clear()
	spell_charges = max_spell_charges
	


func _on_attack_hit(hitbox: HitBox, _hurtbox: HurtBox) -> void:
	var recoil: Vector2 = -Vector2.from_angle(hitbox.global_rotation) * attack_recoil 
	if is_on_floor(): recoil *= grounded_recoil_coeff
	velocity = recoil
	dash_time_left = 0.0

func _on_hurt(_hitbox: HitBox, _hurtbox: HurtBox) -> void:
	dash_time_left = 0.0


func spawn_spell_pickup(coords: Vector2, _velocity: Vector2) -> void: 
	var spell_pickup: SpellPickup = spell_pickup_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(spell_pickup)
	spell_pickup.global_position = coords
	spell_pickup.velocity = _velocity
	spell_pickup.rotation = randf() * PI
	spell_charge_pickups.append(spell_pickup)
