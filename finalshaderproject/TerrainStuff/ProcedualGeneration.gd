extends Node3D

# Variables
@export var itemsToSpread : PackedScene
@export var itemSpawnAmount : int = 10
@export var spreadXPos : float = 10.0
@export var spreadYPos : float = 0.0
@export var spreadZPos : float = 10.0

func _ready() -> void:
	for i in range(itemSpawnAmount):
		SpreadItems()
		
func SpreadItems() -> void:
	var randPos = Vector3(randf_range(-spreadXPos, spreadXPos), randf_range(-spreadYPos, spreadYPos), randf_range(-spreadZPos, spreadZPos))
	var randRot = Quaternion.from_euler(Vector3(0, randf_range(0.0, 360.0), 0))
	var clone = itemsToSpread.instantiate()
	clone.transform.origin = randPos
	clone.transform.basis = Basis(randRot)
	add_child(clone)
	
	
