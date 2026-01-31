class_name EnemyCrawler extends CharacterBody2D

enum BehaviorState {
	IDLE,
	PREPARING,
	STRIKING
}

@export_group("Movement")
@export_subgroup("Physics")
@export var gravity: float = 1400
@export var fall_boost: float = 2.0
@export var friction_exp: float = 0.2
@export var friction_lin: float = 200.0
@export_subgroup("Running")
@export var accel: float = 800.0
@export var max_speed: float = 400.0
@export var attack_momentum := Vector2(800,-500)
@export_subgroup("Behavior")
@export var anticipation_time: float = 0.3
@export var atk_time: float = 0.5
@export var flip_cooldown: float = 0.5



@onready var atk_visual := %AttackVisual
@onready var atk_hitbox := %AttackHitbox
@onready var hurtbox : HurtBox = %HurtBox
@onready var ledge_detector := %LedgeDetector
@onready var wall_detector := %WallDetector
@onready var enemy_detector := %StrikeStartArea

var state: BehaviorState = BehaviorState.IDLE
var orient: float = 1.0

var anticipation_time_left: float
var atk_time_left: float
var flip_cooldown_left: float

var was_hurt: bool = false

func _ready() -> void:
	hurtbox.hurt.connect(_on_hurt)


func _physics_process(delta: float) -> void:
	_process_friction(delta)
	_process_gravity(delta)
	flip_cooldown_left -= delta
	match state:
		BehaviorState.IDLE:
			if is_on_floor():
				for i: Area2D in enemy_detector.get_overlapping_areas():
					if !(i is HurtBox): continue
					if (i as HurtBox).team == HurtBox.Team.PLAYER:
						state = BehaviorState.PREPARING
						anticipation_time_left = anticipation_time
			_process_flip()
			_process_run(delta)
		BehaviorState.PREPARING:
			_process_stand(delta)
			anticipation_time_left -= delta
			if anticipation_time_left <= 0.0:
				state = BehaviorState.STRIKING
				velocity = attack_momentum * Vector2(orient,1.0)
				atk_time_left = atk_time
				atk_visual.show()
				atk_hitbox.enabled = true
		BehaviorState.STRIKING:
			_process_run(delta)
			atk_time_left -= delta
			if atk_time_left <= 0.0 or was_hurt:
				atk_visual.hide()
				atk_hitbox.enabled = false
				state = BehaviorState.IDLE
	move_and_slide()
	was_hurt = false


func _process_flip() -> void:
	if (is_on_floor() and !ledge_detector.is_colliding()) or (wall_detector.is_colliding()) or was_hurt:
		_flip()


func _flip() -> void:
	if flip_cooldown_left > 0.0: return
	scale.x *= -1.0
	orient *= -1.0
	flip_cooldown_left = flip_cooldown


func _process_friction(delta) -> void:
	velocity.x = move_toward(velocity.x,0.0,friction_lin * delta)
	velocity.x *= pow(friction_exp,delta)

func _process_gravity(delta) -> void:
	if velocity.y<0:
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * fall_boost * delta

func _process_run(delta) -> void:
	velocity.x = move_toward(velocity.x, orient * max_speed, accel * delta)


func _process_stand(delta) -> void:
	velocity.x = move_toward(velocity.x, 0.0, accel * delta)


func _on_hurt(_hitbox, _hurtbox) -> void:
	was_hurt = true
