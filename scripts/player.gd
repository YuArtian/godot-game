extends CharacterBody2D

class_name Player

# Movement speed (configurable in editor)
@export var move_speed: float = 300.0

# Health system
@export var max_health: int = 100
var current_health: int

# Collision cooldown to prevent rapid damage
var collision_cooldown: float = 0.5
var last_damage_time: float = 0.0

# Signal emitted when player dies
signal player_died

func _ready():
	current_health = max_health
	
	# Connect hitbox area signals
	var hitbox = $Hitbox
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta):
	# Read input
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	
	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	# Set velocity for instant movement (no inertia)
	velocity = input_vector * move_speed
	
	# Move the player
	move_and_slide()

func take_damage(amount: int):
	current_health -= amount
	current_health = max(0, current_health)
	
	if current_health <= 0:
		die()

func die():
	# Stop movement
	velocity = Vector2.ZERO
	
	# Emit death signal
	player_died.emit()

func _on_hitbox_body_entered(body):
	# Check if collision cooldown has passed
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_damage_time < collision_cooldown:
		return
	
	# Check if the body is an enemy
	if body.is_in_group("enemies"):
		take_damage(1)
		last_damage_time = current_time

func _on_hitbox_area_entered(area):
	# Handle area collisions (if enemies use Area2D)
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_damage_time < collision_cooldown:
		return
	
	# Check if the area's parent is an enemy
	var parent = area.get_parent()
	if parent and parent.is_in_group("enemies"):
		take_damage(1)
		last_damage_time = current_time

