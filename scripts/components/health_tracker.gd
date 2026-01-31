@tool
class_name HealthTracker extends Node


@export var max_hp: float = 10.0
@export var killable: Node
@export var reboot_on_death: bool = false

var hp: float

func _ready() -> void:
	hp = max_hp

func _physics_process(_delta: float) -> void:
	if hp <= 0.0:
		if killable: killable.queue_free()
		if reboot_on_death: get_tree().reload_current_scene()
