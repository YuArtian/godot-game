extends Node

class_name GameManager

# References to game objects
var player: Player = null
var enemy_spawner: EnemySpawner = null

# UI elements
var death_label: Label = null
var restart_button: Button = null

func _ready():
	# Find player and enemy spawner in scene
	player = get_node_or_null("../Player")
	enemy_spawner = get_node_or_null("../EnemySpawner")
	
	# Setup connections
	if player:
		player.player_died.connect(_on_player_died)
	
	if enemy_spawner and player:
		enemy_spawner.set_player(player)
	
	# Create death UI
	create_death_ui()

func _process(delta):
	# Update death label position to center of screen
	if death_label:
		var viewport = get_viewport()
		if viewport:
			var viewport_size = viewport.get_visible_rect().size
			death_label.position = viewport_size / 2 - death_label.size / 2

func create_death_ui():
	# Create death label
	death_label = Label.new()
	death_label.text = "Game Over!\nPress R to Restart"
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.add_theme_font_size_override("font_size", 48)
	death_label.visible = false
	
	# Create CanvasLayer to ensure UI is always visible
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "DeathUI"
	add_child(canvas_layer)
	canvas_layer.add_child(death_label)
	
	# Center the label (will be updated in _process)
	death_label.set_anchors_preset(Control.PRESET_CENTER)

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_R):
		if death_label and death_label.visible and get_tree().paused:
			restart_game()

func _on_player_died():
	# Show death message
	if death_label:
		death_label.visible = true
	
	# Pause game
	get_tree().paused = true

func restart_game():
	# Hide death message
	if death_label:
		death_label.visible = false
	
	# Unpause game
	get_tree().paused = false
	
	# Reset player health
	if player:
		player.current_health = player.max_health
		player.velocity = Vector2.ZERO
	
	# Clear all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()

