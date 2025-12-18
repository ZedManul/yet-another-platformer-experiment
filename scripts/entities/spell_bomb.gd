class_name SpellBomb extends Area2D

@export var fall_gravity: float = 1000.0
@export var beam_time: float = 0.05
@export var beam_visual: Line2D
@export var beam_raycast: RayCast2D
@export var beam_hitbox: HitBox
@export var spell_explosion_scene: PackedScene
@export var spell_pickup_scene: PackedScene

var beam_time_left: float = 0.0
var beamed: bool = false
var exploded: bool = false

var exceptions: Array[Area2D]
var velocity: Vector2 = Vector2.ZERO
var spell_owner: PlatformerCharacterController 	

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if not beamed:
		velocity.y += fall_gravity * delta
		global_position += velocity * delta
	else:
		beam_time_left -= delta
		if beam_time_left <= 0:
			queue_free()
	

func beam(hitbox: HitBox) -> void:
	if beamed: return
	beamed = true
	beam_time_left = beam_time
	beam_visual.show()
	var kb = hitbox.get_knockback(global_position)
	if kb.is_equal_approx(Vector2.ZERO):
		explode.call_deferred(global_position)
		queue_free()
		return
	beam_raycast.global_rotation = kb.angle()
	beam_raycast.force_raycast_update()
	beam_hitbox.enabled = true
	if beam_raycast.is_colliding():
		explode.call_deferred(beam_raycast.get_collision_point())


func explode(coords: Vector2) -> void:
	if exploded: return
	exploded = true
	var explosion: HitBox = spell_explosion_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(explosion)
	explosion.global_position = coords
	beam_raycast.add_exception(explosion)
	
	var spell_pickup: SpellPickup = spell_pickup_scene.instantiate()
	get_tree().get_first_node_in_group(&"GameRoot").add_child(spell_pickup)
	spell_pickup.global_position = coords
	spell_pickup.velocity = velocity
	spell_pickup.rotation = randf() * PI
	spell_owner.spell_charge_pickups.append(spell_pickup)

func _on_body_entered(body: Node2D) -> void:
	explode.call_deferred(global_position)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if exceptions.has(area): return
	if not area is HitBox:
		explode.call_deferred(global_position)
		queue_free()
		return
	beam(area)
