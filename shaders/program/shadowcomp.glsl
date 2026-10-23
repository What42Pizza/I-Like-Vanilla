#include "/lib/colored_lighting/coloredLightingUtils.glsl"



// workgroup size (always 8x8x8)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// number of workgroups
#if COLORED_LIGHTING_DIST == 32
	const ivec3 workGroups = ivec3(4, 3, 4);
#elif COLORED_LIGHTING_DIST == 48
	const ivec3 workGroups = ivec3(6, 4, 6);
#elif COLORED_LIGHTING_DIST == 64
	const ivec3 workGroups = ivec3(8, 6, 8);
#elif COLORED_LIGHTING_DIST == 96
	const ivec3 workGroups = ivec3(12, 9, 12);
#elif COLORED_LIGHTING_DIST == 128
	const ivec3 workGroups = ivec3(16, 12, 16);
#elif COLORED_LIGHTING_DIST == 192
	const ivec3 workGroups = ivec3(24, 18, 24);
#elif COLORED_LIGHTING_DIST == 256
	const ivec3 workGroups = ivec3(32, 24, 32);
#elif COLORED_LIGHTING_DIST == 384
	const ivec3 workGroups = ivec3(48, 36, 48);
#elif COLORED_LIGHTING_DIST == 512
	const ivec3 workGroups = ivec3(64, 48, 64);
#else
	const ivec3 workGroups = ivec3(8, 6, 8);
#endif



uniform usampler3D voxelIdsSampler;
uniform sampler3D lightFloodfill1Sampler;
uniform sampler3D lightFloodfill2Sampler;
#extension GL_ARB_shader_image_load_store : enable
writeonly uniform image3D lightFloodfill1;
writeonly uniform image3D lightFloodfill2;



void updateFloodFill(sampler3D inputFloodFill, writeonly image3D outputFloodFill) {
	
	// get camera movement
	ivec3 cameraPos = ivec3(floor(cameraPosition));
	ivec3 prevCameraPos = ivec3(floor(previousCameraPosition));
	ivec3 inputOffset = (voxelRegionCorner + cameraPos) - (prevVoxelRegionCorner + prevCameraPos);
	
	// get voxel id and datas
	ivec3 voxelPos = ivec3(gl_GlobalInvocationID);
	uint voxelId = texelFetch(voxelIdsSampler, voxelPos, 0).r;
	
	// get voxel emission and translucency
	vec3 emission;
	vec3 translucency;
	#define GET_EMISSION
	#define GET_TRANSLUCENCY
	#include "/generated/voxelDatas.glsl"
	if (voxelId == 1) translucency = vec3(0.0);
	
	
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
	
	vec3 newLight = neighborsMax - 1.0 / vec3(19.0, 14.5, 12.0);
	newLight = max(newLight, emission * 0.7);
	newLight *= translucency;
	
	imageStore(outputFloodFill, voxelPos, vec4(newLight, 0.0));
}



void main() {
	if (frameCounter % 2 == 0) {
		updateFloodFill(lightFloodfill1Sampler, lightFloodfill2);
	} else {
		updateFloodFill(lightFloodfill2Sampler, lightFloodfill1);
	}
}
