extends Node

signal contact_made(Possessable) # Called when the ghost can interact with a new object
signal interacted(Possessable) # Called when the ghost interacts with an object

var investigations : Array[Possessable] = []
var recently_interacted : Array[Possessable] = []

func _ready() -> void:
	contact_made.connect(_contact_made)

var last_contact : Possessable = null
func _contact_made(p: Possessable, entered: bool) -> void:
	if entered:
		last_contact = p
	elif last_contact == p:
		last_contact = null

func get_possessables(global_position: Vector3, distance: float) -> Array[Possessable]:
	var possessables : Array[Possessable] = []
	for possessable: Possessable in get_tree().get_nodes_in_group("possessable"):
		possessables.push_back(possessable)
	return possessables

func filter_no_activity(possables: Possessable) -> bool:
	return possables.interactions_since_last_investigation > 0

func get_possessables_with_interactions(global_position: Vector3, distance: float) -> Array[Possessable]:
	return get_possessables(global_position, distance).filter(filter_no_activity)

func sort_by_activity(possessables: Array[Possessable]):
	possessables.sort_custom(func(a: Possessable, b: Possessable) -> bool:
		return a.interactions_since_last_investigation < b.interactions_since_last_investigation
	)

func sort_by_distance(possessables: Array[Possessable], global_position: Vector3):
	possessables.sort_custom(func(a: Possessable, b: Possessable) -> bool:
		return a.trigger_area.global_position.distance_squared_to(global_position) < b.trigger_area.global_position.distance_squared_to(global_position)
	)
