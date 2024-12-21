extends Node


func _ready():	
	# Create a terrain
	var terrain := Terrain3D.new()
	terrain.assets = Terrain3DAssets.new()
	terrain.name = "Terrain3D"
	terrain.set_collision_enabled(false)
	add_child(terrain, true)
	
	var terrainMaterial := Terrain3DMaterial.new()
	terrain.material = terrainMaterial
	terrain.material.world_background = Terrain3DMaterial.NOISE
	terrainMaterial.auto_shader = true
	
	# Create Grass Texture
	var baseTexture := Terrain3DTextureAsset.new()
	baseTexture.albedo_texture = preload("res://Materials/Grass_basecolor.png")
	baseTexture.albedo_color = Color(1, 1, 1, 1)
	baseTexture.uv_scale = 0.1
	baseTexture.name = "Grass Texture"
	baseTexture.id = 0
	
	# Create Dirt Texture
	var overlayTexture := Terrain3DTextureAsset.new()
	overlayTexture.albedo_texture = preload("res://Materials/Dirt_basecolor.png")
	overlayTexture.normal_texture = preload("res://Materials/Dirt_normal.png")	
	overlayTexture.albedo_color = Color(1, 1, 1, 1)
	overlayTexture.uv_scale = 0.1
	overlayTexture.name = "Dirt Texture"
	overlayTexture.id = 1
		
	terrain.assets.texture_list.append(baseTexture)
	terrain.assets.texture_list.append(overlayTexture)
	
	terrainMaterial.set_shader_param("base_texture", baseTexture)
	terrainMaterial.set_shader_param("overlay_texture", overlayTexture)
	
	terrainMaterial.texture_filtering = Terrain3DMaterial.TextureFiltering.LINEAR
		
	# Generate 32-bit noise and import it with scale
	var noise := FastNoiseLite.new()
	noise.frequency = 0.0010
	var img: Image = Image.create(2048, 2048, false, Image.FORMAT_RF)
	for x in 2048:
		for y in 2048:
			img.set_pixel(x, y, Color(noise.get_noise_2d(x, y)*0.5, 0., 0., 1.))
	terrain.data.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 300.0)

	# Enable collision. Enable the first if you wish to see it with Debug/Visible Collision Shapes
	#terrain.set_show_debug_collision(true)
	terrain.set_collision_enabled(true)
	
	
	
