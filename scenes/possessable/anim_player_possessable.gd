# Possession that uses an AnimationPlayer
class_name AnimPlayerPossessable
extends Possessable

# animation player to
@export var anim_player: AnimationPlayer

@export var scare_anim: Array[String]

func _scare() -> void:
	anim_player.play(scare_anim.front())
	scare_anim.push_back(scare_anim.pop_front())
