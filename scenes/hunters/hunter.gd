extends CharacterBody3D

@export var nav_agent : NavigationAgent3D

enum STATE {
	IDLE,
	EXPLORING,
	INVESTIGATING,
	HUNTING
}
	
const SPEED := 5.0
const MAX_FEAR := 100.0

var random = null

var state = STATE.EXPLORING
var nav_point := Vector3.ZERO
var fear := 0.0

var compute_first_frame := false

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func _physics_process(delta):
	
	if (!compute_first_frame):
		compute_first_frame = true
		return	
		
	if state == STATE.EXPLORING:
		if (nav_agent.is_navigation_finished()):
			
			var search_expand := 0.0
			while(true):
				var rand_dist = randf_range(3, 10)
				var rand_rot = PI/3 * search_expand * random.randfn()
				
				var curr_velocity_norm = velocity.normalized()
				if curr_velocity_norm == Vector3.ZERO:
					curr_velocity_norm = Vector3.BACK
				
				var target_random : Vector3 = curr_velocity_norm * rand_dist
				target_random = target_random.rotated(Vector3.UP, rand_rot) + global_transform.origin
			
				nav_agent.set_target_position(target_random)
				
				if (nav_agent.is_target_reachable()):
					break
					
				search_expand += 1.0

	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * SPEED
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	pass
	#velocity = safe_velocity
	#print(velocity)
