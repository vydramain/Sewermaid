# AIInputProvider.gd
extends InputProvider
class_name AIInputProvider

@export var ai_difficulty: float = 0.5  # 0.0 = easy, 1.0 = hard
@export var reaction_time: float = 0.3  # How fast AI reacts (seconds)
@export var aggression: float = 0.5  # How often AI attacks vs defends

var target_character: CharacterBody2D = null
var owner_character: CharacterBody2D = null

var _next_action_time: float = 0.0
var _current_action: String = ""
var _action_duration: float = 0.0
var _decision_cooldown: float = 0.0

const ACTIONS = {
	"LOW_KICK": "button_cross",
	"MIDDLE_PUNCH": "button_square",
	"LOW_SHIELD": "button_triangle",
	"MIDDLE_SHIELD": "button_circle"
}

func _ready() -> void:
	_next_action_time = Time.get_ticks_msec() / 1000.0 + reaction_time

func set_target(target: CharacterBody2D) -> void:
	target_character = target

func set_character(character: CharacterBody2D) -> void:
	owner_character = character

func _process(delta: float) -> void:
	if target_character and owner_character:
		var dir_to_target = target_character.global_position.x - owner_character.global_position.x
		if abs(dir_to_target) > 10:
			owner_character.facing_right = dir_to_target > 0
			if owner_character.sprite.scale.x > 0 and not owner_character.facing_right:
				owner_character.sprite.scale.x *= -1
				owner_character.hit_box_collision_low.scale.x *= -1
				owner_character.hit_box_collision_middle.scale.x *= -1
				owner_character.hurt_box_collision_low.scale.x *= -1
				owner_character.hurt_box_collision_middle.scale.x *= -1
			elif owner_character.sprite.scale.x < 0 and owner_character.facing_right:
				owner_character.sprite.scale.x *= -1
				owner_character.sprite.scale.x *= -1
				owner_character.hit_box_collision_low.scale.x *= -1
				owner_character.hit_box_collision_middle.scale.x *= -1
				owner_character.hurt_box_collision_low.scale.x *= -1
				owner_character.hurt_box_collision_middle.scale.x *= -1
	
	_decision_cooldown -= delta
	if _action_duration > 0:
		_action_duration -= delta
	else:
		_current_action = ""

func get_movement_direction() -> Vector2:
	if not target_character or not owner_character:
		return Vector2.ZERO
	
	var distance_to_target = owner_character.global_position.distance_to(target_character.global_position)
	var direction_to_target = (target_character.global_position - owner_character.global_position).normalized()
	
	# Determine optimal distance based on aggression
	var optimal_distance = 0
	
	# Move towards or away from target to maintain optimal distance
	if distance_to_target > optimal_distance + 20:
		return Vector2(sign(direction_to_target.x), 0)
	elif distance_to_target < optimal_distance - 20:
		return Vector2(-sign(direction_to_target.x), 0)
	
	# Add some randomness to movement
	if randf() < 0.1:  # 10% chance each frame to move randomly
		return Vector2(randf_range(-10, 10), 0).normalized()
	
	return Vector2.ZERO

func is_action_just_pressed(action: String) -> bool:
	if not target_character or not owner_character:
		return false
	
	# Only make decisions when cooldown is ready
	if _decision_cooldown > 0:
		return false
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Check if it's time to consider a new action
	if current_time < _next_action_time:
		return false
	
	# If we already decided on an action, execute it once
	if _current_action != "" and _current_action == action:
		var result = true
		_current_action = ""  # Clear after returning true once
		_decision_cooldown = 0.2  # Small cooldown between actions
		_next_action_time = current_time + reaction_time * randf_range(0.8, 1.2)
		return result
	
	# Make a new decision
	if _current_action == "":
		_decide_next_action()
		if _current_action == action:
			return true
	
	return false

func _decide_next_action() -> void:
	if not target_character or not owner_character:
		return
	
	var distance = owner_character.global_position.distance_to(target_character.global_position)
	var my_hp = owner_character.hp if "hp" in owner_character else 100
	var target_hp = target_character.hp if "hp" in target_character else 100
	
	# Calculate action probabilities based on situation
	var should_attack = randf() < aggression
	var in_range = distance < 120
	
	# Adjust behavior based on HP
	if my_hp < 30:
		should_attack = randf() < (aggression * 0.5)  # More defensive when low HP
	elif target_hp < 30:
		should_attack = randf() < (aggression * 1.3)  # More aggressive when enemy is low
	
	# Only attack if in range
	if should_attack and in_range:
		# Choose attack type
		if randf() < 0.5:
			_current_action = ACTIONS["MIDDLE_PUNCH"]
		else:
			_current_action = ACTIONS["LOW_KICK"]
		_action_duration = 0.3
	elif in_range and randf() < 0.3:  # 30% chance to defend when close
		# Choose defense type
		if randf() < 0.5:
			_current_action = ACTIONS["MIDDLE_SHIELD"]
		else:
			_current_action = ACTIONS["LOW_SHIELD"]
		_action_duration = 0.4
	else:
		_current_action = ""  # No action, just move
		_decision_cooldown = 0.1

func get_provider_name() -> String:
	return "AI (Difficulty: %.1f)" % ai_difficulty
