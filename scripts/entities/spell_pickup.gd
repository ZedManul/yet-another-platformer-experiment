class_name SpellPickup extends CharacterBody2D



@export var activation_delay: float = 1.0
var activation_delay_left: float = activation_delay

@export var gravity: Vector2 = Vector2(0,1000.0)
@export var friction: float = 0.5


@onready var activity_indicator: Polygon2D = %ActivityIndicator


func _physics_process(delta: float) -> void:
	activation_delay_left = move_toward(activation_delay_left,0.0,delta)
	velocity += gravity * delta
	velocity *= pow(friction,delta)
	
	if !velocity.is_zero_approx(): global_rotation = velocity.angle()
	
	move_and_slide()
	
	if activation_delay_left > 0: return
	activity_indicator.show()
