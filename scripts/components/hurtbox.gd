class_name HurtBox extends Area2D

@export var enabled: bool = true
@export var subcomponents: Array[HurtBoxSubcomponent]
@export var exceptions: Array[HitBox]
@export_group("Invincibility Frames")
@export var invincibility_time: float = 0.5 # seconds

var inv_time_left: float 
var hitboxes: Array[HitBox]


func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	process_timers(delta)
	if inv_time_left > 0.0 or not enabled: return
	process_hit()


func process_hit() -> void:
	if hitboxes.is_empty(): return
	inv_time_left = invincibility_time
	for hitbox in hitboxes:
		hitbox.on_hit.emit(hitbox,self)
		for comp in subcomponents:
			if comp.process(self,hitbox.damage_data): break


func process_timers(delta: float) -> void:
	inv_time_left = max(0.0, inv_time_left - delta)


func _on_area_entered(area: Area2D) -> void:
	if not (area is HitBox): return
	if area in exceptions: return
	if area in hitboxes: return
	hitboxes.append(area)


func _on_area_exited(area: Area2D) -> void:
	if not area in hitboxes: return
	var hitbox_idx: int = hitboxes.find(area)
	hitboxes.remove_at(hitbox_idx)
