extends Control

@export var main_scene: Node2D = null

func _on_player_vs_player_pressed() -> void:
	if main_scene != null and main_scene.has_method("run_p_vs_p"):
		main_scene.run_p_vs_p()


func _on_player_vs_ai_pressed() -> void:
	if main_scene != null and main_scene.has_method("run_p_vs_ai"):
		main_scene.run_p_vs_ai()


func _on_a_ivs_ai_pressed() -> void:
	if main_scene != null and main_scene.has_method("run_p_vs_p"):
		main_scene.run_ai_vs_ai()
