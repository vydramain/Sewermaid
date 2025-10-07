extends InputProvider
class_name ControllerInputProvider

@export var controller_device: int = 0

enum ControllerType {
	UNKNOWN,
	PLAYSTATION,
	XBOX
}

var controller_type: ControllerType = ControllerType.UNKNOWN
var _previous_button_states: Dictionary = {}

# --- LAYOUT MAPS ---
const PLAYSTATION_MAP: Dictionary = {
	"button_square": JOY_BUTTON_X,
	"button_cross": JOY_BUTTON_A,
	"button_circle": JOY_BUTTON_B,
	"button_triangle": JOY_BUTTON_Y,
	"button_l1": JOY_BUTTON_LEFT_SHOULDER,
	"button_r1": JOY_BUTTON_RIGHT_SHOULDER,
	"button_l2": JOY_BUTTON_LEFT_STICK,
	"button_r2": JOY_BUTTON_RIGHT_STICK,
}

const XBOX_MAP: Dictionary = PLAYSTATION_MAP  # identical mapping for now

# --- INITIALIZATION ---
func _ready() -> void:
	_detect_controller_type()

func _detect_controller_type() -> void:
	var controller_name: String = Input.get_joy_name(controller_device).to_lower()

	if controller_name.findn("playstation") != -1 or controller_name.findn("ps4") != -1 or controller_name.findn("ps5") != -1 \
	or controller_name.findn("dualshock") != -1 or controller_name.findn("dualsense") != -1:
		controller_type = ControllerType.PLAYSTATION
	elif controller_name.findn("xbox") != -1 or controller_name.findn("xinput") != -1:
		controller_type = ControllerType.XBOX
	else:
		controller_type = ControllerType.UNKNOWN

	var layout: String = "Unknown"
	match controller_type:
		ControllerType.PLAYSTATION:
			layout = "PlayStation"
		ControllerType.XBOX:
			layout = "Xbox"
		_:
			layout = "Unknown"

	print("Controller %d detected as %s" % [controller_device, layout])

# --- INPUT METHODS ---
func get_movement_direction() -> Vector2:
	var dir: Vector2 = Vector2.ZERO
	var x_axis: float = Input.get_joy_axis(controller_device, JOY_AXIS_LEFT_X)
	if absf(x_axis) > 0.2:
		dir.x = x_axis

	# Digital fallback
	if Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_RIGHT):
		dir.x = 1.0
	elif Input.is_joy_button_pressed(controller_device, JOY_BUTTON_DPAD_LEFT):
		dir.x = -1.0

	return dir.normalized()

func is_action_just_pressed(action: String) -> bool:
	if action == "button_l2" or action == "button_r2":
		return _is_trigger_just_pressed(action)

	var button: int = _get_button_for_action(action)
	if button == -1:
		return false

	var key: String = "%d_%d" % [controller_device, button]
	var pressed: bool = Input.is_joy_button_pressed(controller_device, button)
	var was_pressed: bool = _previous_button_states.get(key, false)
	_previous_button_states[key] = pressed
	return pressed and not was_pressed


func _is_trigger_just_pressed(action: String) -> bool:
	var axis_index: int = -1
	if action == "button_l2":
		axis_index = JOY_AXIS_TRIGGER_LEFT
	elif action == "button_r2":
		axis_index = JOY_AXIS_TRIGGER_RIGHT
	else:
		return false

	var axis_value: float = Input.get_joy_axis(controller_device, axis_index)
	var threshold: float = 0.6  # adjust if needed
	var key: String = "%d_trigger_%d" % [controller_device, axis_index]

	var pressed: bool = axis_value > threshold
	var was_pressed: bool = _previous_button_states.get(key, false)
	_previous_button_states[key] = pressed

	return pressed and not was_pressed

# --- INTERNAL HELPERS ---
func _get_button_for_action(action: String) -> int:
	match controller_type:
		ControllerType.PLAYSTATION:
			return PLAYSTATION_MAP.get(action, -1)
		ControllerType.XBOX:
			return XBOX_MAP.get(action, -1)
		_:
			return XBOX_MAP.get(action, -1)

func get_provider_name() -> String:
	var layout: String = "Unknown"
	match controller_type:
		ControllerType.PLAYSTATION:
			layout = "PlayStation"
		ControllerType.XBOX:
			layout = "Xbox"
		_:
			layout = "Unknown"

	return "Controller %d (%s)" % [controller_device, layout]
