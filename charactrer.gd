extends CharacterBody2D

@onready var sprite = $SpriteBox
@onready var animation_player = $SpriteBox/AnimationPlayer

@onready var collision = $CollisionShape2D
@onready var hit_box_collision = $Hitbox/CollisionShape2D
@onready var hurt_box_collision_low = $HurtBox/LowCollisionShape
@onready var hurt_box_collision_middle = $HurtBox/MiddleCollisionShape

@export var winner_script: Control

@export var speed: float = 40.0
@export var accel: float = 125.0
@export var friction: float = 600.0

@export var hp: int = 100
@export var character_name: String

# Export the controller device ID
@export var controller_device: int = 0  # 0 = Player 1, 1 = Player 2, etc.

# Export starting direction
@export var start_facing_right: bool = true  # Set initial direction character faces

var attacking: bool = false
var facing_right: bool = true

# Track previous button states for just_pressed detection
var _previous_button_states = {}

const ACTIONS = {
	"LOW_KICK": "Low_Kick",
	"MIDDLE_PUNCH": "Middle_Punch"
}

# Button mapping constants
enum ControllerType {
	UNKNOWN,
	PLAYSTATION,
	XBOX
}

var controller_type: ControllerType = ControllerType.UNKNOWN

func _ready() -> void:
	hurt_box_collision_low.disabled = true
	hurt_box_collision_middle.disabled = true
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Set initial facing direction
	facing_right = start_facing_right
	if not start_facing_right:
		# Flip sprite and collisions to face left
		sprite.scale.x *= -1
		collision.position.x *= -1
		hit_box_collision.position.x *= -1
		hurt_box_collision_low.position.x *= -1
		hurt_box_collision_middle.position.x *= -1
	
	# Detect controller type
	detect_controller_type()


func detect_controller_type() -> void:
	var joy_name = Input.get_joy_name(controller_device).to_lower()
	
	if joy_name.contains("playstation") or joy_name.contains("ps4") or joy_name.contains("ps5") or joy_name.contains("dualshock") or joy_name.contains("dualsense"):
		controller_type = ControllerType.PLAYSTATION
		print("Player %d: PlayStation controller detected" % (controller_device + 1))
	elif joy_name.contains("xbox") or joy_name.contains("xinput"):
		controller_type = ControllerType.XBOX
		print("Player %d: Xbox controller detected" % (controller_device + 1))
	else:
		# Default to Xbox layout as it's more common
		controller_type = ControllerType.XBOX
		print("Player %d: Unknown controller, using Xbox layout" % (controller_device + 1))


func _physics_process(delta: float) -> void:
	if attacking:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		var input_dir = get_input_direction()
		
		if input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(speed * input_dir, accel * delta)
	
			# flip direction
			if input_dir.x != 0 and ((input_dir.x > 0 and not facing_right) or (input_dir.x < 0 and facing_right)):
				flip_direction()
	
			if animation_player.current_animation != "Walk":
				animation_player.play("Walk")
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle")
	
		# Device-specific input for attacks
		if is_button_just_pressed("button_square"):
			start_attack(ACTIONS["MIDDLE_PUNCH"])
		if is_button_just_pressed("button_cross"):
			start_attack(ACTIONS["LOW_KICK"])
	
	move_and_slide()


func flip_direction() -> void:
	facing_right = not facing_right
	sprite.scale.x *= -1

	# Mirror collision shapes
	collision.position.x *= -1
	hit_box_collision.position.x *= -1
	hurt_box_collision_low.position.x *= -1
	hurt_box_collision_middle.position.x *= -1


func get_input_direction() -> Vector2:
	var input_dir: Vector2 = Vector2.ZERO
	
	# Get left stick horizontal axis
	var axis_value = Input.get_joy_axis(controller_device, JOY_AXIS_LEFT_X)
	
	# Apply deadzone
	if abs(axis_value) > 0.2:
		input_dir.x = axis_value
	
	# Also support D-pad
	if Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_RIGHT):
		input_dir.x = 1.0
	elif Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_LEFT):
		input_dir.x = -1.0
	
	return input_dir.normalized()


func is_button_just_pressed(action: String) -> bool:
	var button = get_joy_button_for_action(action)
	if button != -1:
		var key = str(controller_device) + "_" + str(button)
		var is_pressed = Input.is_joy_button_pressed(controller_device, button)
		var was_pressed = _previous_button_states.get(key, false)
		_previous_button_states[key] = is_pressed
		return is_pressed and not was_pressed
	return false


func get_joy_button_for_action(action: String) -> int:
	match action:
		"button_square":
			# PlayStation: Square (left face button)
			# Xbox: X (left face button)
			if controller_type == ControllerType.PLAYSTATION:
				return JOY_BUTTON_X  # Square on PlayStation
			else:  # Xbox or unknown
				return JOY_BUTTON_X  # X on Xbox
		
		"button_cross":
			# PlayStation: Cross (bottom face button)
			# Xbox: A (bottom face button)
			if controller_type == ControllerType.PLAYSTATION:
				return JOY_BUTTON_A  # Cross on PlayStation
			else:  # Xbox or unknown
				return JOY_BUTTON_A  # A on Xbox
		
		"button_circle":
			# PlayStation: Circle (right face button)
			# Xbox: B (right face button)
			if controller_type == ControllerType.PLAYSTATION:
				return JOY_BUTTON_B  # Circle on PlayStation
			else:  # Xbox or unknown
				return JOY_BUTTON_B  # B on Xbox
		
		"button_triangle":
			# PlayStation: Triangle (top face button)
			# Xbox: Y (top face button)
			if controller_type == ControllerType.PLAYSTATION:
				return JOY_BUTTON_Y  # Triangle on PlayStation
			else:  # Xbox or unknown
				return JOY_BUTTON_Y  # Y on Xbox
		
		"button_l1":
			return JOY_BUTTON_LEFT_SHOULDER
		
		"button_r1":
			return JOY_BUTTON_RIGHT_SHOULDER
		
		"button_l2":
			return JOY_BUTTON_LEFT_STICK  # L2/LT trigger (as button)
		
		"button_r2":
			return JOY_BUTTON_RIGHT_STICK  # R2/RT trigger (as button)
		
		_:
			return -1


# --- ATTACK HANDLING ---
func start_attack(anim_name: String) -> void:
	if anim_name == ACTIONS["MIDDLE_PUNCH"]:
		attacking = true
	if anim_name == ACTIONS["LOW_KICK"]:
		attacking = true
	
	animation_player.play(anim_name)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ACTIONS["MIDDLE_PUNCH"]:
		attacking = false
	if anim_name == ACTIONS["LOW_KICK"]:
		attacking = false
	
	animation_player.play("Idle")


# --- ANIMATION NOTIFIES ---
func _enable_middle_hitbox() -> void:
	hurt_box_collision_middle.disabled = false

func _disable_middle_hitbox() -> void:
	hurt_box_collision_middle.disabled = true

func _enable_low_hitbox() -> void:
	hurt_box_collision_low.disabled = false

func _disable_low_hitbox() -> void:
	hurt_box_collision_low.disabled = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	hp -= 10
	
	if winner_script != null and winner_script.has_method("set_game_over") == true and hp == 0:
		winner_script.set_game_over(true, character_name)
