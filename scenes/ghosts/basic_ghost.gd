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

func _ready():
	blend_tree.active = true

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
		else:
			velocity = velocity.move_toward(Vector3.ZERO, .8)

	blend_tree.set("parameters/move_anim/blend_amount", remap(Vector2(velocity.x, velocity.z).length(), 0, speed, -1, .5))
	move_and_slide()

func take_damage(damage: float):
	HUD.health_bar.value -= damage
	HUD.energy_bar.value += damage * .8 # Gain energy from damage
