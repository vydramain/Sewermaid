extends Control

@export var main_scene: Node2D = null
@export var menu: Control = null

func _ready() -> void:
	self.visible = false

func _on_piss_button_pressed() -> void:
	if main_scene != null and "player_choose" in main_scene:
		main_scene.player_choose = "piss"
		main_scene.setup_game()


func _on_poop_button_pressed() -> void:
	if main_scene != null and "player_choose" in main_scene:
		main_scene.player_choose = "poop"
		main_scene.setup_game()
