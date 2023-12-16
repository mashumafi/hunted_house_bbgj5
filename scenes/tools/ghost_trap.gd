extends Area3D

@export var anim_player : AnimationPlayer

var activated := false

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
				
func end_trap():
	queue_free()
