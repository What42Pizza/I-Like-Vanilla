#include "/lib/colored_lighting/coloredLightingUtils.glsl"



void updateFloodFill(sampler3D inputFloodFill, writeonly image3D outputFloodFill, bool needsOffset) {
	
	// get camera movement
	ivec3 cameraPos = ivec3(floor(cameraPosition));
	ivec3 prevCameraPos = ivec3(floor(previousCameraPosition));
	ivec3 inputOffset = (voxelRegionCorner + cameraPos) - (prevVoxelRegionCorner + prevCameraPos);
	if (!needsOffset) inputOffset = ivec3(0);
	
	// get voxel id and datas
	ivec3 voxelPos = ivec3(gl_GlobalInvocationID);
	uint voxelId = texelFetch(voxelIdsSampler, voxelPos, 0).r;
	
	// get voxel emission and translucency
	vec3 emission;
	vec3 translucency;
	#define GET_EMISSION
	#define GET_TRANSLUCENCY
	#include "/generated/voxelDatas.glsl"
	if (voxelId == 0) { emission = vec3(0.0); translucency = vec3(1.0); }
	if (voxelId == 1) { emission = vec3(0.0); translucency = vec3(0.0); }
	emission = mix(vec3(getLum(emission)), emission, COLORED_LIGHTING_SATURATION);
	emission *= EMISSION_SETTINGS_MULT * 0.5;
	
	// get max of neighbors
	vec3 neighborsMax = vec3(0.0);
	#define SAMPLE_MAX_LIGHT(x, y, z) neighborsMax = max(neighborsMax, texelFetch(inputFloodFill, voxelPos + inputOffset + ivec3(x, y, z), 0).rgb);
	SAMPLE_MAX_LIGHT(0, 0, 0);
	SAMPLE_MAX_LIGHT(-1, 0, 0);
	SAMPLE_MAX_LIGHT(0, -1, 0);
	SAMPLE_MAX_LIGHT(0, 0, -1);
	SAMPLE_MAX_LIGHT(1, 0, 0);
	SAMPLE_MAX_LIGHT(0, 1, 0);
	SAMPLE_MAX_LIGHT(0, 0, 1);
	
	// get new light value
	vec3 newLight = neighborsMax - lightTransmittanceDecrease;
	newLight *= translucency;
	newLight = max(newLight, emission);
	
	imageStore(outputFloodFill, voxelPos, vec4(newLight, float(voxelId != 1)));
}
