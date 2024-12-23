extends Node

@export var itemsToSpread : Array[PackedScene]
@export var itemSpawnAmount : int = 5
@export var noiseImage : Texture2D
@export var noiseSeed : int
@export var waterShader : PackedScene

@export_category("Terrain Texturing")

@export var textureList : Array[Terrain3DTextureAsset] = []

@export var baseName : String
@export var baseTexture : Texture2D
@export var baseNormal : Texture2D
@export var baseID : int
@export var baseAlbedoColor : Color
@export var baseUVScale : float

@export var overlayName : String
@export var overlayTexture : Texture2D
@export var overlayNormal : Texture2D
@export var overlayID : int
@export var overlayAlbedoColor : Color
@export var overlayUVScale : float

@export var waterHeight : float = -65

var spawnedWater : Array = []
var spawnedItems : Array = []

func _ready():	
	# Create a terrain
	var terrain := Terrain3D.new()
	terrain.assets = Terrain3DAssets.new()
	terrain.name = "Terrain3D"
	terrain.set_collision_enabled(false)
	add_child(terrain, true)
	terrain.material.world_background = Terrain3DMaterial.NOISE
	
	var terrainMaterial := Terrain3DMaterial.new()
	terrainMaterial.auto_shader = true
	terrain.material = terrainMaterial
	
	# Create Grass Texture
	var bTexture := Terrain3DTextureAsset.new()
	bTexture.albedo_texture = baseTexture
	bTexture.albedo_color = baseAlbedoColor
	bTexture.normal_texture = baseNormal
	bTexture.uv_scale = baseUVScale
	bTexture.name = baseName
	bTexture.id = baseID
	print(bTexture.albedo_texture, bTexture.albedo_color, bTexture.uv_scale, bTexture.name, bTexture.id)
	
	# Create Dirt Texture
	var oTexture := Terrain3DTextureAsset.new()
	oTexture.albedo_texture = overlayTexture
	oTexture.normal_texture = overlayNormal	
	oTexture.albedo_color = overlayAlbedoColor
	oTexture.uv_scale = overlayUVScale
	oTexture.name = overlayName
	oTexture.id = overlayID
	print(oTexture.albedo_texture, oTexture.albedo_color, oTexture.uv_scale, oTexture.name, oTexture.id)

	# Add textures to the terrain assets texture list
	textureList.append(bTexture)
	textureList.append(oTexture)
	terrain.assets.set_texture_list(textureList)
	
	textureList = terrain.assets.texture_list
	
	# Sets the base and overlay textures
	terrainMaterial.set_shader_param("auto_base_texture", 0)
	terrainMaterial.set_shader_param("auto_overlay_texture", 1)
	terrainMaterial.set_shader_param("dual_scale_texture", 0)
	
	terrainMaterial.texture_filtering = Terrain3DMaterial.TextureFiltering.LINEAR
	terrainMaterial.set_shader_param("height_blending", true)
	print(terrainMaterial.get_shader_param("height_blending"))
		
	# Generate 32-bit noise and import it with scale
	if noiseImage == null:
		var noise := FastNoiseLite.new()
		noise.frequency = 0.0010
		noise.seed = noiseSeed
		var img: Image = Image.create(2048, 2048, false, Image.FORMAT_RF)
		for x in 2048:
			for y in 2048:
				img.set_pixel(x, y, Color(noise.get_noise_2d(x, y) * 0.5, 0.0, 0.0, 1.0))
		terrain.data.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 300.0)
	elif noiseImage != null:
		var image = noiseImage.get_image()
		terrain.data.import_images([image, null, null], Vector3(-1024, 0, -1024), 0.0, 300.0)

	# Enable collision. Enable the first if you wish to see it with Debug/Visible Collision Shapes
	#terrain.set_show_debug_collision(true)
	terrain.set_collision_enabled(true)
	terrain.set_collision_layer(1)
	terrain.set_collision_mask(1 | 2)
	terrain.set_collision_priority(1)
	
	# Spreading the fooliage
	for i in range(itemSpawnAmount):
		SpreadItems(terrain)
				
# Function to get the height of the terrain at specific points	
func GetHeightAtPoint(globalPos : Vector3, terrain : Terrain3D) -> float:
	if terrain != null and terrain.data != null:
		return terrain.data.get_height(globalPos)
	return 0.0
	
func GenerateRandPos(terrain : Terrain3D, regionLoc : Vector2i) -> Vector3:
	
	var regionSize = terrain.region_size
	
	var minBounds = Vector3(regionLoc.x * regionSize, 0, regionLoc.y * regionSize)
	var maxBounds = minBounds + Vector3(regionSize, 0, regionSize)
	
	# Generate random pos
	var randXPos = randf_range(minBounds.x, maxBounds.x)
	var randZPos = randf_range(minBounds.z, maxBounds.z)
	var randYPos = GetHeightAtPoint(Vector3(randXPos, 0.0, randZPos), terrain)
	
	# Set random pos and rotation
	return Vector3(randXPos, randYPos, randZPos)
		
	
func Overlapping(newPos : Vector3) -> bool:
	for item in spawnedItems:
		var itemPos = item.global_transform.origin
		if itemPos.distance_to(newPos) < 20.0:
			return true
	return false
			
func IsInWater(newPos : Vector3) -> bool:
	return (newPos.y <= waterHeight)
		
# Function that spreads the items
func SpreadItems(terrain : Terrain3D) -> void:
	if terrain == null:
		push_error("Terrain missing!")
		return
	elif terrain.data == null:
		push_error("Data missing")
		return
		
	var randRot = Quaternion.from_euler(Vector3(0, randf_range(0.0, 360.0), 0))
	var allRegions = terrain.data.get_regions_all()

	for regionLoc in allRegions.keys():			
		# Instantiate and place items
		if itemsToSpread != null:
			var randomObj = itemsToSpread.pick_random()
			var clone = randomObj.instantiate()
			var newPos = GenerateRandPos(terrain, regionLoc)
			
			while Overlapping(newPos) or IsInWater(newPos):
				newPos = GenerateRandPos(terrain, regionLoc)
				
			clone.transform.origin = newPos
			clone.transform.basis = Basis(randRot)
			
			# Adds collision detection
			var area = Area3D.new()
			var collisionShape = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			collisionShape.shape = shape
			area.add_child(collisionShape)
			clone.add_child(area)
			
			clone.add_to_group("clones")
			spawnedItems.append(clone)
			add_child(clone)
			
			if waterShader != null:
				var waterClone = waterShader.instantiate()
				# Scale water shader
				waterClone.scale = Vector3(terrain.region_size, 1, terrain.region_size)
				waterClone.transform.origin = Vector3(regionLoc.x * terrain.region_size, waterHeight, regionLoc.y * terrain.region_size)
				
				spawnedWater.append(waterClone)
				add_child(waterClone)
				print("Water Height: ", waterHeight)
