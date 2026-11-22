#include "/lib/colored_lighting/coloredLightingUtils.glsl"



void updateFloodFill() {
	
	// get camera movement
	#ifdef IS_FIRST_UPDATE
		ivec3 cameraPos = ivec3(floor(cameraPosition));
		ivec3 prevCameraPos = ivec3(floor(previousCameraPosition));
		ivec3 inputOffset = (voxelRegionCorner + cameraPos) - (prevVoxelRegionCorner + prevCameraPos);
	#else
		const ivec3 inputOffset = ivec3(0);
	#endif
	
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
	emission *= 0.5; // reminder: if one block's emissive light is larger than other's, it won't necessarily look brighter (brightness is controlled only and entirely by the vanilla lmcoord), but its color will more easily overpower the other light's color, so the only purpose of this line is to allow input values to go up to 2.0
	
	// get max of neighbors
	vec3 neighborsMax = vec3(0.0);
	#define SAMPLE_MAX_LIGHT(x, y, z) neighborsMax = max(neighborsMax, texelFetch(INPUT_SAMPLER, voxelPos + inputOffset + ivec3(x, y, z), 0).rgb);
	SAMPLE_MAX_LIGHT(-1, 0, 0);
	SAMPLE_MAX_LIGHT(0, -1, 0);
	SAMPLE_MAX_LIGHT(0, 0, -1);
	SAMPLE_MAX_LIGHT(1, 0, 0);
	SAMPLE_MAX_LIGHT(0, 1, 0);
	SAMPLE_MAX_LIGHT(0, 0, 1);
	
	// get new light value
	vec3 newLight = neighborsMax * 0.8; // constant 20% brightness drop from one block to the next
	newLight *= translucency;
	newLight = max(newLight, emission);
	
	imageStore(OUTPUT_IMAGE, voxelPos, vec4(newLight, 1));
}
