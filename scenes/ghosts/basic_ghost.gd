extends CharacterBody3D

@export
var speed := 2.5

@export
var gravity := -9.8

@export
var ghost : Node3D

@export
var blend_tree : AnimationTree

func _process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	velocity = velocity.move_toward(Vector3(direction.x, velocity.y + gravity, direction.y), .4)
	if is_on_floor():
		velocity.y = 0

	if velocity.length_squared() > 0:
		ghost.rotation.y = lerp(ghost.rotation.y, atan2(velocity.x, velocity.z), .2)

	blend_tree.set("parameters/move_anim/blend_amount", remap(Vector2(velocity.x, velocity.z).length(), 0, speed, -1, .5))

	move_and_slide()
