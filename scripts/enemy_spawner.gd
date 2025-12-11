extends Node

class_name EnemySpawner

# Spawn interval in seconds (configurable in editor)
@export var spawn_interval: float = 1.0

# Enemy scene to spawn
@export var enemy_scene: PackedScene

# Reference to player
var player: Node2D = null

# Timer for spawning
var spawn_timer: Timer

func _ready():
	# Create and configure timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func set_player(player_node: Node2D):
	player = player_node

func _on_timer_timeout():
	if player != null and enemy_scene != null:
		spawn_enemy()

func spawn_enemy():
	if player == null:
		return
	
	# Get viewport size
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	
	# Get camera to convert screen coordinates to world coordinates
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	
	# Get camera's world position
	var camera_pos = camera.global_position
	
	# Randomly choose one of the four screen edges
	var edge = randi() % 4
	var spawn_position = Vector2.ZERO
	
	match edge:
		0:  # Top edge
			spawn_position = Vector2(randf() * viewport_size.x, -50)
		1:  # Bottom edge
			spawn_position = Vector2(randf() * viewport_size.x, viewport_size.y + 50)
		2:  # Left edge
			spawn_position = Vector2(-50, randf() * viewport_size.y)
		3:  # Right edge
			spawn_position = Vector2(viewport_size.x + 50, randf() * viewport_size.y)
	
	# Convert screen coordinates to world coordinates
	spawn_position = camera_pos + spawn_position - viewport_size / 2
	
	# Instantiate enemy
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_position
	
	# Set target to player
	if enemy_instance.has_method("set_target"):
		enemy_instance.set_target(player)
	
	# Add to scene tree
	get_tree().current_scene.add_child(enemy_instance)

