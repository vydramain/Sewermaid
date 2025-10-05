extends Camera2D

# Assign your two character nodes in the editor
@export var character1: CharacterBody2D
@export var character2: CharacterBody2D

# Camera settings
@export var follow_smoothing: float = 5.0  # Higher = slower/smoother
@export var zoom_smoothing: float = 3.0
@export var smooth_zoom: bool = false  # Toggle smooth zoom on/off

# Zoom settings
@export var min_zoom: float = 0.5  # Zoomed out (see more)
@export var max_zoom: float = 1.5  # Zoomed in (see less)
@export var default_zoom: float = 1.0
@export var zoom_margin: float = 200.0  # Extra space around characters

var target_position: Vector2
var target_zoom: float


func _ready() -> void:
	# Enable the camera
	enabled = true
	
	# Set initial zoom
	zoom = Vector2(default_zoom, default_zoom)
	target_zoom = default_zoom
	
	# Validate characters are assigned
	if not character1 or not character2:
		push_error("Camera: Both characters must be assigned!")


func _process(delta: float) -> void:
	if not character1 or not character2:
		return
	
	# Calculate center point between both characters
	var center = (character1.global_position + character2.global_position) / 2.0
	target_position = center
	
	# Calculate distance between characters
	var distance = character1.global_position.distance_to(character2.global_position)
	
	# Adjust zoom based on distance
	# The further apart they are, the more we zoom out
	var desired_zoom = default_zoom
	if distance > zoom_margin:
		# Calculate zoom to fit both characters
		desired_zoom = clamp(
			(zoom_margin / distance) * default_zoom,
			min_zoom,
			max_zoom
		)
	else:
		desired_zoom = default_zoom
	
	target_zoom = desired_zoom
	
	# Smooth camera movement
	global_position = global_position.lerp(target_position, follow_smoothing * delta)
	
	# Apply zoom (smooth or instant)
	if smooth_zoom:
		var current_zoom_value = zoom.x
		var new_zoom_value = lerp(current_zoom_value, target_zoom, zoom_smoothing * delta)
		zoom = Vector2(new_zoom_value, new_zoom_value)
	else:
		zoom = Vector2(target_zoom, target_zoom)
	
	# Apply camera limits
	apply_limits()


func apply_limits() -> void:
	# Get the viewport size to calculate actual camera bounds
	var viewport_size = get_viewport_rect().size
	var camera_half_width = (viewport_size.x / zoom.x) / 2.0
	var camera_half_height = (viewport_size.y / zoom.y) / 2.0
	
	# Apply limits with camera size consideration
	if limit_left != -10000 or limit_right != 10000:
		var min_x = limit_left + camera_half_width
		var max_x = limit_right - camera_half_width
		global_position.x = clamp(global_position.x, min_x, max_x)
	
	if limit_top != -10000 or limit_bottom != 10000:
		var min_y = limit_top + camera_half_height
		var max_y = limit_bottom - camera_half_height
		global_position.y = clamp(global_position.y, min_y, max_y)


# Optional: Call this to shake the camera (for hit effects, etc.)
func shake(intensity: float = 10.0, duration: float = 0.2) -> void:
	var original_offset = offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	
	offset = original_offset
