extends Control

@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var timer_label: Label = $VBoxContainer/TimerLabel

@export var countdown_time: float = 6.0
@export var game_scene_path: String = "res://sewer_area.tscn"

var time_remaining: float = 0.0
var has_restarted: bool = false
var is_game_over: bool = false
var winner_name: String = "Unknown"


func _ready() -> void:
	# Neutral startup, no error
	winner_label.text = ""
	timer_label.text = ""


func _process(delta: float) -> void:
	if not is_game_over or has_restarted:
		return
		
	time_remaining -= delta
	
	if time_remaining <= 0:
		restart_game()
	else:
		update_timer_display()


func update_timer_display() -> void:
	var seconds = ceil(time_remaining)
	timer_label.text = "Restarting in %d..." % seconds


func restart_game() -> void:
	if has_restarted:
		return
	
	has_restarted = true
	
	if get_tree().root.has_meta("winner_name"):
		get_tree().root.remove_meta("winner_name")
	
	get_tree().change_scene_to_file(game_scene_path)


func set_game_over(game_over: bool, character_name: String) -> void:
	is_game_over = game_over
	winner_name = character_name

	if is_game_over:
		# store data for other systems if needed
		get_tree().root.set_meta("winner_name", winner_name)

		# update UI and start countdown
		winner_label.text = "%s WINS!" % winner_name.to_upper()
		time_remaining = countdown_time
		update_timer_display()
