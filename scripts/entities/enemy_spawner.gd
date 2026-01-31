class_name EnemySpawner extends Marker2D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 3
@export var spawn_interval: float = 10.0

var enemy_instances: Array[Node2D]
var spawn_interval_left: float


func _physics_process(delta: float) -> void:
	if !enemy_scene: return
	var clear_queue: Array[int]
	for i: int in enemy_instances.size():
		if enemy_instances[i]: continue
		clear_queue.append(i)
	clear_queue.reverse()
	for i: int in clear_queue:
		enemy_instances.remove_at(i)
	
	
	if enemy_instances.size() < max_enemies:
		if spawn_interval_left > 0:
			spawn_interval_left -= delta
			return
		var new_enemy: Node2D = enemy_scene.instantiate()
		get_tree().get_first_node_in_group("GameRoot").add_child(new_enemy)
		new_enemy.global_transform = global_transform
		enemy_instances.append(new_enemy)
		spawn_interval_left = spawn_interval
