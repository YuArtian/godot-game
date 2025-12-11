extends CharacterBody2D

class_name Enemy

# Movement speed (configurable in editor)
@export var move_speed: float = 300.0

# Target to chase (usually the player)
var target: Node2D = null

func _ready():
	# Add to enemies group for collision detection
	add_to_group("enemies")

func _physics_process(delta):
	if target == null:
		return
	
	# Calculate direction to target
	var direction = (target.global_position - global_position).normalized()
	
	# Set velocity for instant movement (no inertia)
	velocity = direction * move_speed
	
	# Move the enemy
	move_and_slide()

func set_target(target_node: Node2D):
	target = target_node

