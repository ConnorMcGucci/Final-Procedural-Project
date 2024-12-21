extends Node3D

# Variables
@export var raycastDistance : float = 100.0
@export var overlap : float = 1.0
@export var objectToSpawn : PackedScene
@export var itemSelection : Array[PackedScene]

func _ready() -> void:
	positionRaycast()
	
func positionRaycast() -> void:
	# Perform downward raycast from the current position
	var spaceState = get_world_3d().direct_space_state
	var from = global_transform.origin
	var to = from - Vector3.UP * raycastDistance
	
	# Create a RayCast query for the raycast
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	
	# Perform Raycast
	var result = spaceState.intersect_ray(query)
	if result:
		var hitPosition = result.position
		var hitNormal = result.normal
		
		# Align the rotation to the hit surface
		var spawnRotation = Transform3D().looking_at(hitPosition + hitNormal, Vector3.UP).basis
		
		var overlapScale = Vector3(overlap, overlap, overlap)
		var colliderBox = [1]
		
		
func randomSelect(positionToSpawn : Vector3, relationToSpawn : Quaternion) -> void:
	var randomIndex = randi_range(0, len(itemSelection))
	var clone = itemSelection[randomIndex].instantiate()
	clone.transform.origin = positionToSpawn
	add_child(clone)
