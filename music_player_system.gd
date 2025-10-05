extends Node

const dict = {
	"pp_cw_amen10_160": preload("res://pp_cw_amen10_160.ogg"),
	"pa_cw_amen10_160": preload("res://pa_cw_amen10_160.ogg"),
}

const next_state = {
	"pp_cw_amen10_160": "pp_cw_amen10_160",
	"pa_cw_amen10_160": "pa_cw_amen10_160",
}

const events_to_states = {
	"arena": "pp_cw_amen10_160",
	"danger_arena": "pp_cw_amen10_160",
}

var audio_player: AudioStreamPlayer = null
var state: String = "arena"


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = dict.get(state, dict.get("pp_cw_amen10_160"))
	audio_player.autoplay = true
	add_child(audio_player)

func _process(delta: float) -> void:
	if not audio_player:
		return

	if not audio_player.playing:
		state = next_state.get(state, state)
		audio_player.stream = dict.get(state, dict.get("pp_cw_amen10_160"))
		audio_player.play()


func play_next(event: String) -> void:
	state = events_to_states[event]
	audio_player.stream = dict.get(state, dict.get("pp_cw_amen10_160"))
	audio_player.play()
