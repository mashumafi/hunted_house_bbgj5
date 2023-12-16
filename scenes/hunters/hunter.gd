extends CharacterBody3D

@export var nav_agent : NavigationAgent3D
@export var anim_tree : AnimationTree
@export var flashlight : Node3D
@export var detect_area : Area3D
@export var model : Node3D

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
var ghost : Node3D = null

var compute_first_frame := false

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()
	anim_tree.active = true

func _physics_process(delta):
	
	if (!compute_first_frame):
		compute_first_frame = true
		return	
		
	if state == STATE.HUNTING: # chase the ghost
		var space_state = get_world_3d().direct_space_state
		
		var query = PhysicsRayQueryParameters3D.create(global_position, ghost.global_position)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		
		if !result.has("collider") or result["collider"] != ghost:
			state = STATE.EXPLORING
			ghost = null
			anim_tree.set("parameters/hold_blend/blend_amount", 0)
			flashlight.hide()
			return
		
		
		nav_agent.set_target_position(ghost.global_position)
		
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		
		if global_position.distance_to(ghost.global_position) < 2: # ghost is too close
			velocity *= velocity.move_toward(-1 * global_position.direction_to(next_path_position),  delta * SPEED)	
		else:
			velocity = velocity.move_toward(global_position.direction_to(next_path_position),  delta * SPEED)	
			
		model.look_at(ghost.global_position) # TODO LERP
		model.rotate_y(PI)
		
	if state == STATE.EXPLORING:
		if detect_area.has_overlapping_bodies(): # TODO decide on collison layers for ghost detection
			for body in detect_area.get_overlapping_bodies():
				if body.is_in_group("ghost"):
					var space_state = get_world_3d().direct_space_state
					
					var query = PhysicsRayQueryParameters3D.create(global_position, body.global_position)
					query.exclude = [self]
					var result := space_state.intersect_ray(query)
					
					if result.has("collider") and result["collider"] == body:
						state = STATE.HUNTING
						ghost = body
						anim_tree.set("parameters/hold_blend/blend_amount", 1)
						flashlight.show()
						return
				 		
		
		if (nav_agent.is_navigation_finished()): # find a new random point to move towards
			
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
		velocity = velocity.move_toward(global_position.direction_to(next_path_position), delta * SPEED)
		
		model.look_at(next_path_position) # TODO LERP
		model.rotate_y(PI)
	
	anim_tree.set("parameters/move_anim/blend_amount", remap(velocity.length(), 0, SPEED, -1, 1))
	
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	pass
	#velocity = safe_velocity
	#print(velocity)
