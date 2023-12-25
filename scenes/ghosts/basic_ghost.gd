extends CharacterBody3D

enum State
{
	Default,
	Possessing,
}

var state := State.Default

@export
var speed := 2.5

@export
var gravity := -9.8

@export
var ghost : Node3D

@export
var blend_tree : AnimationTree

const POSSESSION_DURATION := 1.0

@onready var possession_meter : ProgressBar = $PossessionBarViewport/PoissessionMeter3D
@onready var possession_meter_sprite : Sprite3D = $PossessionMeterTexture
@onready var possession_meter_particles: CPUParticles3D = $PossessionCPUParticles3D

@onready var ghost_torso : MeshInstance3D = $"character-ghost/character-ghost/root/torso"
@onready var ghost_arm_left : MeshInstance3D = $"character-ghost/character-ghost/root/torso/arm-left"
@onready var ghost_arm_right : MeshInstance3D = $"character-ghost/character-ghost/root/torso/arm-right"

@onready var torso_surface_override : StandardMaterial3D = ghost_torso.mesh.surface_get_material(0).duplicate()
@onready var arm_left_surface_override : StandardMaterial3D = ghost_arm_left.mesh.surface_get_material(0).duplicate()
@onready var arm_right_surface_override : StandardMaterial3D = ghost_arm_right.mesh.surface_get_material(0).duplicate()

@onready var sizzle_audio : AudioStreamPlayer = $SizzleAudioStreamPlayer

var recently_damaged := false

func _ready():
	blend_tree.active = true

	ghost_torso.set_surface_override_material(0, torso_surface_override)
	ghost_arm_left.set_surface_override_material(0, arm_left_surface_override)
	ghost_arm_right.set_surface_override_material(0, arm_right_surface_override)

var _possession_target: Possessable
var _timer_id: int

func _process(delta: float) -> void:
	if state == State.Default:
		HUD.energy_bar.value += delta * 10
		if Input.is_action_just_pressed("interact") and ParanormalActivity.last_contact:
			state = State.Possessing
			possession_meter_sprite.visible = true
			possession_meter_particles.emitting = true
			possession_meter.value = 0.0
			HUD.show_vignette()
			create_tween().tween_property(possession_meter, "value", 100.0, POSSESSION_DURATION)
			_possession_target = ParanormalActivity.last_contact
			var timer_id := Engine.get_process_frames()
			_timer_id = timer_id
			get_tree().create_timer(POSSESSION_DURATION).timeout.connect(func():
				if state == State.Possessing and _timer_id == timer_id:
					_possession_target.possess()
					var spawn := Node3D.new()
					get_parent().add_child(spawn)
					spawn.global_position = global_position
					spawn.add_to_group("ghost")
					self.queue_free()
			)
		else:
			var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
			velocity = velocity.move_toward(Vector3(direction.x, velocity.y + gravity, direction.y), .4)
			if is_on_floor():
				velocity.y = 0

			if velocity.length_squared() > 0:
				ghost.rotation.y = lerp(ghost.rotation.y, atan2(velocity.x, velocity.z), .2)
	elif state == State.Possessing:
		HUD.energy_bar.value -= delta * 25
		if Input.is_action_just_released("interact") or HUD.energy_bar.value == 0.0:
			state = State.Default
			possession_meter_sprite.visible = false
			possession_meter_particles.emitting = false
			HUD.hide_vignette()
		else:
			velocity = velocity.move_toward(Vector3.ZERO, .8)

	blend_tree.set("parameters/move_anim/blend_amount", remap(Vector2(velocity.x, velocity.z).length(), 0, speed, -1, .5))
	move_and_slide()

func take_damage(damage: float):
	HUD.health_bar.value -= damage
	HUD.energy_bar.value += damage * .8 # Gain energy from damage

	if not recently_damaged:
		sizzle_audio.play()
		var hurt := func(mat: StandardMaterial3D) -> void:
			var tween := create_tween()
			tween.tween_property(mat, "albedo_color", Color.RED, .25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.tween_property(mat, "albedo_color", Color.WHITE, .25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(.25)
			recently_damaged = true
			tween.tween_callback(func():
				recently_damaged = false
				sizzle_audio.stop()
			)

		hurt.call(torso_surface_override)
		hurt.call(arm_left_surface_override)
		hurt.call(arm_right_surface_override)
