extends Area3D

const DAMAGE_PER_SECOND = 20

@export var anim_player : AnimationPlayer
@export var trap_audio : AudioStreamPlayer3D

var activated := false
var ghost : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if !activated and has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("ghost"):
				activated = true
				anim_player.play("activate")
				ghost = body
				trap_audio.play()
				
	if activated and is_instance_valid(ghost):
		ghost.take_damage(delta * DAMAGE_PER_SECOND)
		
				
func end_trap():
	queue_free()


func _on_body_exited(body):
	ghost = null
