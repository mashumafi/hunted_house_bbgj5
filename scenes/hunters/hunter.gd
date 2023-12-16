extends CharacterBody3D

@export var nav_agent : NavigationAgent3D
@export var anim_tree : AnimationTree
@export var flashlight : Node3D
@export var detect_area : Area3D
@export var model : Node3D
@export var investigate_timer: Timer

enum STATE {
	IDLE,
	EXPLORING,
	INVESTIGATING,
	HUNTING
}
	
const SPEED := 1.0
const JOG_SPEED := 1.3
const RUN_SPEED := 1.6
const ACCEL := 5.0
const MAX_FEAR := 100.0

const GRAVITY = -9.8

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
		
		var query = PhysicsRayQueryParameters3D.create(
			global_position + Vector3(0, 0.25, 0), 
			ghost.global_position + Vector3(0, 0.25, 0), 
			0x1,  # 1 in hexadecimal for 1st collision layer
			[self])
		var result := space_state.intersect_ray(query)
		
		if !result.has("collider") or result["collider"] != ghost:
			state = STATE.INVESTIGATING
			ghost = null
			#anim_tree.set("parameters/hold_blend/blend_amount", 0)
			#flashlight.hide()
			return
		
		
		nav_agent.set_target_position(ghost.global_position)
		
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		
		if global_position.distance_to(ghost.global_position) < 2: # ghost is too close
			velocity = velocity.move_toward(-1 * global_position.direction_to(next_path_position) * RUN_SPEED,  delta * ACCEL)	
		else:
			velocity = velocity.move_toward(global_position.direction_to(next_path_position) * RUN_SPEED,  delta * ACCEL)	
			
		var g_pos = ghost.global_position
		var new_transform = model.global_transform.looking_at(Vector3(g_pos.x, position.y, g_pos.z), Vector3.UP, true)

		model.global_transform = model.global_transform.interpolate_with(new_transform, ACCEL * delta)
		
	elif state == STATE.EXPLORING or state == STATE.INVESTIGATING:
		if detect_area.has_overlapping_bodies(): # TODO decide on collison layers for ghost detection
			for body in detect_area.get_overlapping_bodies():
				if body.is_in_group("ghost"):
					var space_state = get_world_3d().direct_space_state
					
					var query = PhysicsRayQueryParameters3D.create(
						global_position + Vector3(0, 0.25, 0), 
						body.global_position + Vector3(0, 0.25, 0), 
						0x1,  # 1 in hexadecimal for 1st collision layer
						[self])
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
		var speed = SPEED
		if state == STATE.INVESTIGATING:
			speed = JOG_SPEED

		velocity = velocity.move_toward(global_position.direction_to(next_path_position) * speed, delta * ACCEL)

		var p_pos = next_path_position
		
		var new_transform = model.global_transform.looking_at(Vector3(p_pos.x, position.y + 0.01 , p_pos.z), Vector3.UP, true)
		model.global_transform = model.global_transform.interpolate_with(new_transform, ACCEL * delta)
		#model.look_at(next_path_position, Vector3.UP, true) # TODO LERP

	anim_tree.set("parameters/move_anim/blend_amount", remap(velocity.length(), 0, RUN_SPEED, -1, 1))
	velocity += Vector3(0, GRAVITY * delta, 0)
	
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
	print(velocity)


func _on_investigate_timer_timeout():
	if state == STATE.INVESTIGATING:
		state = STATE.EXPLORING
		anim_tree.set("parameters/hold_blend/blend_amount", 0)
		flashlight.hide()
