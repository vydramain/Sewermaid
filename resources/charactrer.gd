# Character.gd (Refactored)
extends CharacterBody2D

@onready var sound_death = preload("res://assets/music/pp_death.ogg")
@onready var sound_impact = preload("res://assets/music/pp_impact.ogg")
@onready var sound_punch = preload("res://assets/music/pp_punch.mp3")

@onready var sprite = $SpriteBox
@onready var animation_player = $SpriteBox/AnimationPlayer

@onready var collision = $CollisionShape2D
@onready var hit_box_collision_low = $Hitbox/LowCollisionShape2D
@onready var hit_box_collision_middle = $Hitbox/MiddleCollisionShape2D
@onready var hurt_box_collision_low = $HurtBox/LowCollisionShape
@onready var hurt_box_collision_middle = $HurtBox/MiddleCollisionShape

@onready var particles = $CPUParticles2D
@onready var particles_trails = $CPUTrailsParticles2D

@export var winner_script: Control

@export var speed: float = 80.0
@export var accel: float = 125.0
@export var friction: float = 1500.0

@export var hp: int = 100
@export var character_name: String

# Export starting direction
@export var start_facing_right: bool = true

# INPUT PROVIDER - Set this in the scene!
var input_provider: InputProvider = null

var attacking: bool = false
var defencing: bool = false
var sliding: bool = false
var facing_right: bool = true
var _low_hp_triggered: bool = false
var _audio_player: AudioStreamPlayer

const ACTIONS = {
	"LOW_KICK": "Low_Kick",
	"MIDDLE_PUNCH": "Middle_Punch",
	"LOW_SHIELD": "Low_Shield",
	"MIDDLE_SHIELD": "Middle_Shield",
	"SLIDE": "Slide"
}

func _ready() -> void:
	particles.emitting = false
	
	hurt_box_collision_low.disabled = true
	hurt_box_collision_middle.disabled = true
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.set_speed_scale(3.0)
	
	_audio_player = AudioStreamPlayer.new()
	_audio_player.volume_db = +6.0
	add_child(_audio_player)
	
	# Set initial facing direction
	facing_right = start_facing_right
	if not start_facing_right:
		sprite.scale.x *= -1
		collision.position.x *= -1
		hit_box_collision_middle.position.x *= -1
		hit_box_collision_low.position.x *= -1
		hurt_box_collision_low.position.x *= -1
		hurt_box_collision_middle.position.x *= -1
	
	# If no input provider is set, create a default controller provider
	if input_provider == null:
		print("Warning: No input provider set for %s, creating default controller" % character_name)
		set_controller_input(0)

# Method to set controller input
func set_controller_input(device_id: int = 0) -> void:
	if input_provider:
		input_provider.queue_free()
	
	var controller = ControllerInputProvider.new()
	controller.controller_device = device_id
	add_child(controller)
	input_provider = controller
	print("%s: Using controller %d" % [character_name, device_id])

# Method to set AI input
func set_ai_input(target: CharacterBody2D, difficulty: float = 0.5, aggression: float = 0.5) -> void:
	if input_provider:
		input_provider.queue_free()
	
	var ai = AIInputProvider.new()
	ai.ai_difficulty = difficulty
	ai.aggression = aggression
	add_child(ai)
	ai.set_target(target)
	ai.set_character(self)
	input_provider = ai
	print("%s: Using AI (Difficulty: %.1f, Aggression: %.1f)" % [character_name, difficulty, aggression])

# Method to set custom input provider
func set_input_provider(provider: InputProvider) -> void:
	if input_provider:
		input_provider.queue_free()
	
	add_child(provider)
	input_provider = provider
	print("%s: Using %s" % [character_name, provider.get_provider_name()])

func _physics_process(delta: float) -> void:
	if attacking or defencing or sliding or hp <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		var input_dir = get_input_direction()
		
		if input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(speed * input_dir, accel * delta)
			
			# flip direction
			if input_dir.x != 0 and ((input_dir.x > 0 and not facing_right) or (input_dir.x < 0 and facing_right)):
				flip_direction()
			
			if animation_player.current_animation != "Moving":
				animation_player.play("Moving")
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle")
	
		# Check for attacks using input provider
		if input_provider:
			if input_provider.is_action_just_pressed("button_square"):
				start_attack(ACTIONS["MIDDLE_PUNCH"])
			if input_provider.is_action_just_pressed("button_cross"):
				start_attack(ACTIONS["LOW_KICK"])
			if input_provider.is_action_just_pressed("button_circle"):
				start_defence(ACTIONS["MIDDLE_SHIELD"])
			if input_provider.is_action_just_pressed("button_triangle"):
				start_defence(ACTIONS["LOW_SHIELD"])
			if input_provider.is_action_just_pressed("button_l2"): 
				if facing_right:
					slide(delta, Vector2(-1, 0), ACTIONS["SLIDE"])
				else: 
					slide(delta, Vector2(1, 0), ACTIONS["SLIDE"])
			if input_provider.is_action_just_pressed("button_r2"): 
				if facing_right:
					slide(delta, Vector2(1, 0), ACTIONS["SLIDE"])
				else: 
					slide(delta, Vector2(-1, 0), ACTIONS["SLIDE"])
	
	move_and_slide()
	_check_low_hp()
	
	if hp <= 0: 
		facing_right = not facing_right
		sprite.scale.x *= -1
		particles.direction.x = 0
		particles.direction.y = -1
		particles.emitting = true

func get_input_direction() -> Vector2:
	if input_provider:
		return input_provider.get_movement_direction()
	return Vector2.ZERO

func _check_low_hp() -> void:
	if hp < 40 and not _low_hp_triggered:
		_low_hp_triggered = true
		_on_low_hp()

func _on_low_hp() -> void:
	if MUSIC_PLAYER_SYSTEM:
		MUSIC_PLAYER_SYSTEM.play_next("danger_arena")

func flip_direction() -> void:
	facing_right = not facing_right
	sprite.scale.x *= -1
	collision.position.x *= -1
	hit_box_collision_middle.position.x *= -1
	hit_box_collision_low.position.x *= -1
	hurt_box_collision_low.position.x *= -1
	hurt_box_collision_middle.position.x *= -1

func teleport(dir: Vector2, distance: float = 100.0):
	if dir == Vector2.ZERO:
		# If no input, teleport forward based on facing direction
		dir = Vector2(1 if facing_right else -1, 0)
	
	global_position += dir.normalized() * distance

func slide(delta: float, dir: Vector2, anim_name: String, distance: float = 100.0, duration: float = 0.6) -> void:
	if anim_name == ACTIONS["SLIDE"]:
		sliding = true
	
	animation_player.play(anim_name)
	
	if dir == Vector2.ZERO:
		dir = Vector2(1 if facing_right else -1, 0)
	
	dir = dir.normalized()
	var start_pos = global_position
	var end_pos = start_pos + dir * distance
	var elapsed = 0.0
	
	while elapsed < duration:
		elapsed += delta
		var t = elapsed / duration
		global_position = start_pos.lerp(end_pos, t)
		await get_tree().process_frame


func start_defence(anim_name: String) -> void:
	if anim_name == ACTIONS["MIDDLE_SHIELD"]:
		defencing = true
	if anim_name == ACTIONS["LOW_SHIELD"]:
		defencing = true
	
	animation_player.play(anim_name)

func start_attack(anim_name: String) -> void:
	if anim_name == ACTIONS["MIDDLE_PUNCH"]:
		attacking = true
	if anim_name == ACTIONS["LOW_KICK"]:
		attacking = true
	
	animation_player.play(anim_name)
	_audio_player.stream = sound_punch
	_audio_player.play()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == ACTIONS["MIDDLE_PUNCH"]:
		attacking = false
	if anim_name == ACTIONS["LOW_KICK"]:
		attacking = false
	if anim_name == ACTIONS["MIDDLE_SHIELD"]:
		defencing = false
	if anim_name == ACTIONS["LOW_SHIELD"]:
		defencing = false
	if anim_name == ACTIONS["SLIDE"]:
		sliding = false
	
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

func _enable_middle_hurtbox() -> void:
	hit_box_collision_middle.disabled = false

func _disable_middle_hurtbox() -> void:
	hit_box_collision_middle.disabled = true

func _enable_low_hurtbox() -> void:
	hit_box_collision_low.disabled = false

func _disable_low_hurtbox() -> void:
	hit_box_collision_low.disabled = true

func _enable_all_collisions() -> void:
	collision.disabled = false

func _disable_all_collisions() -> void:
	collision.disabled = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	hp -= 10
	
	_audio_player.stream = sound_impact
	_audio_player.play()
	
	if hp <= 0:
		if hp == 0 and winner_script != null and winner_script.has_method("set_game_over"):
			_audio_player.stream = sound_death
			_audio_player.play()
			winner_script.set_game_over(true, character_name)
			hit_box_collision_middle.disabled = true
			hit_box_collision_low.disabled = true
			hit_box_collision_middle.disabled = true
	
	if facing_right == true:
		particles.direction.x = -1
	else:
		particles.direction.x = 1
	particles.emitting = true
	particles.emitting = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	pass
