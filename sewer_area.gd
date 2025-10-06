extends Node2D

@onready var player1 = $Piss
@onready var player2 = $Poop

@onready var menu = $CanvasLayer/Menu

enum GameMode {
	TWO_PLAYERS,
	PLAYER_VS_AI,
	AI_VS_AI
}

@export var game_mode: GameMode = GameMode.PLAYER_VS_AI
@export var ai_difficulty: float = 0.5
@export var ai_aggression: float = 0.6

func _ready() -> void:
	if MUSIC_PLAYER_SYSTEM:
		MUSIC_PLAYER_SYSTEM.play_next('arena')

func run_p_vs_p() -> void:
	game_mode = GameMode.TWO_PLAYERS
	menu.visible = false
	setup_game()

func run_p_vs_ai() -> void:
	game_mode = GameMode.PLAYER_VS_AI
	menu.visible = false
	setup_game()

func run_ai_vs_ai() -> void:
	game_mode = GameMode.AI_VS_AI
	menu.visible = false
	setup_game()

func setup_game() -> void:
	match game_mode:
		GameMode.TWO_PLAYERS:
			setup_two_players()
		GameMode.PLAYER_VS_AI:
			setup_player_vs_ai()
		GameMode.AI_VS_AI:
			setup_ai_vs_ai()

func setup_two_players() -> void:
	# Player 1 uses controller 0
	player1.set_controller_input(0)
	
	# Player 2 uses controller 1
	player2.set_controller_input(1)
	
	print("Game Mode: Two Players")

func setup_player_vs_ai() -> void:
	# Player 1 uses controller 0
	player1.set_controller_input(1)
	
	# Player 2 is AI
	player2.set_ai_input(player1, ai_difficulty, ai_aggression)
	
	print("Game Mode: Player vs AI")

func setup_ai_vs_ai() -> void:
	# Both players are AI
	player1.set_ai_input(player2, ai_difficulty, ai_aggression)
	player2.set_ai_input(player1, ai_difficulty, ai_aggression * 0.8)
	
	print("Game Mode: AI vs AI")

# You can also change input during gameplay
func switch_to_ai(player: CharacterBody2D, opponent: CharacterBody2D) -> void:
	player.set_ai_input(opponent, ai_difficulty, ai_aggression)

func switch_to_controller(player: CharacterBody2D, device_id: int) -> void:
	player.set_controller_input(device_id)
