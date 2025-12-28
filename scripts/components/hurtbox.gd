class_name HurtBox extends Area2D

signal hurt(hitbox: HitBox, hurtbox: HurtBox)

enum TEAM {
	PLAYER,
	ENEMY,
	ENVIRONMENT,
	COMBO_PROJECTILES
}


@export var enabled: bool = true
@export var subcomponents: Array[HurtBoxSubcomponent]
@export var team: TEAM
@export_group("Invincibility Frames")
@export var invincibility_time: float = 0.5 # seconds
var invincibility_timers: Dictionary[int, float]


func _physics_process(delta: float) -> void:
	process_timers(delta)
	if not enabled: return
	process_hit()


func process_hit() -> void:
	var hitboxes: Array[HitBox] 
	for area: Area2D in get_overlapping_areas():
		if not area is HitBox: continue
		hitboxes.append(area)
	if hitboxes.is_empty(): return
	for hitbox: HitBox in hitboxes:
		if hitbox.exceptions.has(self): continue
		if hitbox.ignored_teams.has(team): continue
		if invincibility_timers.keys().has(hitbox.get_instance_id()): return
		invincibility_timers[hitbox.get_instance_id()] = invincibility_time
		hitbox.hit.emit(hitbox,self)
		hurt.emit(hitbox,self)
		for comp in subcomponents:
			if comp.process(self,hitbox): break



func process_timers(delta: float) -> void:
	var expired: Array[int]
	for hb in invincibility_timers.keys():
		invincibility_timers[hb]-=delta
		if invincibility_timers[hb]<=0:
			expired.append(hb)
	
	for hb in expired:
		invincibility_timers.erase(hb)
	expired.clear()
	
