shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0, 0.1) = 0;
uniform float roughness : hint_range(0.0, 1.0, 0.1) = 0.02;

uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

uniform vec2 waveDirection = vec2(2.0,0.0);
uniform vec2 waveDirection2 = vec2(0.0,1.0);
uniform float timeScale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noiseScale = 10.0;
uniform float heightScale = 0.15;

uniform vec4 colorDeep : source_color;
uniform vec4 colorShallow : source_color;
uniform float beersLaw = 2.0;
uniform float depthOffset = -0.75;

uniform float edgeScale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edgeColor : source_color;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Varying Variable
varying float height;
varying vec3 worldPos;

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float edge(float depth){
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void vertex(){
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, worldPos.xz / noiseScale + TIME * timeScale).r;
	VERTEX.y += height * heightScale;
}

void fragment() {
	float depthTexture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depthTexture * PROJECTION_MATRIX[2][2]);
	float depthBlend = exp((depth+VERTEX.z + depthOffset) * -beersLaw);
	depthBlend = clamp(1.0 - depthBlend, 0.0, 1.0);
	float depthBlendPower = clamp(pow(depthBlend, 2.5), 0.0, 1.0);
	
	vec3 screenColor = textureLod(SCREEN_TEXTURE, SCREEN_UV, depthBlendPower * 2.5).rgb;
	vec3 depthColor = mix(colorShallow.rgb, colorDeep.rgb, depthBlendPower);
	vec3 color = mix(screenColor * depthColor, depthColor * 0.25, depthBlendPower * 0.5);
	
	float zDepth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float zPos = edge(FRAGCOORD.z);
	float zDif= zDepth - zPos;
	
	vec2 time = (TIME * waveDirection) * timeScale;
	vec2 time2 = (TIME * waveDirection2) * timeScale;
	
	vec3 normalBlend = mix(texture(texture_normal, UV + time).rgb, texture(texture_normal2, UV + time2).rgb, 0.5);
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surfaceColor = mix(albedo, albedo2, fresnel);
	
	vec3 depthColorAdj = mix(edgeColor, color, step(edgeScale, zDif));
	
	ALBEDO = surfaceColor;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normalBlend;
}


