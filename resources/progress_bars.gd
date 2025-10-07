extends Control

# Assign your character nodes
@export var character1: CharacterBody2D  # Piss
@export var character2: CharacterBody2D  # Poop

# Progress bar nodes (will be found automatically by name)
@onready var health_bar1: TextureProgressBar = $PissProgressBar
@onready var health_bar2: TextureProgressBar = $PoopProgressBar

# Maximum HP for progress bars
@export var max_hp: float = 100.0


func _ready() -> void:
	# Validate assignments
	if not character1 or not character2:
		push_error("HealthBarManager: Both characters must be assigned!")
		return
	
	if not health_bar1 or not health_bar2:
		push_error("HealthBarManager: Both health bars must be assigned!")
		return
	
	# Initialize progress bars
	health_bar1.max_value = max_hp
	health_bar1.value = max_hp
	
	health_bar2.max_value = max_hp
	health_bar2.value = max_hp

func _process(delta: float) -> void:
	# Update health bars every frame automatically
	update_health_bars()


func update_health_bars() -> void:
	# Safely check if characters still exist and are valid
	if is_instance_valid(character1) and health_bar1:
		health_bar1.value = character1.hp
	
	if is_instance_valid(character2) and health_bar2:
		health_bar2.value = character2.hp


# Optional: Smooth health bar animation
func animate_health_change(health_bar: TextureProgressBar, new_value: float, duration: float = 0.3) -> void:
	var tween = create_tween()
	tween.tween_property(health_bar, "value", new_value, duration)
