extends Node2D

func _ready() -> void:
	if MUSIC_PLAYER_SYSTEM:
		MUSIC_PLAYER_SYSTEM.play_next('arena')
