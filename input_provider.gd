# Base class for all input providers
extends Node
class_name InputProvider

# Virtual methods to be implemented by child classes
func get_movement_direction() -> Vector2:
	return Vector2.ZERO

func is_action_just_pressed(action: String) -> bool:
	return false

func get_provider_name() -> String:
	return "Base Input Provider"
