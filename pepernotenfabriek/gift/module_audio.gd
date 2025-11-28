extends Node2D
class_name ModuleAudioGift

@export var audio_player : AudioStreamPlayer2D
var audio_playback : AudioStreamPlaybackPolyphonic

@export var audio_deliver : AudioStream
@export var audio_fail : AudioStream
@export var audio_appear : AudioStream

func _ready() -> void:
	var stream := AudioStreamPolyphonic.new()
	audio_player.stream = stream
	audio_player.play()
	audio_playback = audio_player.get_stream_playback()

func play_appear() -> void:
	audio_playback.play_stream(audio_appear, 0, -3, AudioManager.get_pitch_shift_semitones())

func play_deliver() -> void:
	audio_playback.play_stream(audio_deliver, 0, 0, AudioManager.get_pitch_shift_semitones())

func play_fail() -> void:
	audio_playback.play_stream(audio_fail, 0, -3, AudioManager.get_pitch_shift_semitones())
