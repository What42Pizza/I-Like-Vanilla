#include "/lib/colored_lighting/coloredLightingUtils.glsl"



// workgroup size (always 8x8x8)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// number of workgroups
#if COLORED_LIGHTING_DIST == 32
	const ivec3 workGroups = ivec3(4, 2, 4);
#elif COLORED_LIGHTING_DIST == 48
	const ivec3 workGroups = ivec3(6, 3, 6);
#elif COLORED_LIGHTING_DIST == 64
	const ivec3 workGroups = ivec3(8, 4, 8);
#elif COLORED_LIGHTING_DIST == 96
	const ivec3 workGroups = ivec3(12, 6, 12);
#elif COLORED_LIGHTING_DIST == 128
	const ivec3 workGroups = ivec3(16, 8, 16);
#elif COLORED_LIGHTING_DIST == 192
	const ivec3 workGroups = ivec3(24, 12, 24);
#elif COLORED_LIGHTING_DIST == 256
	const ivec3 workGroups = ivec3(32, 16, 32);
#elif COLORED_LIGHTING_DIST == 384
	const ivec3 workGroups = ivec3(48, 24, 48);
#elif COLORED_LIGHTING_DIST == 512
	const ivec3 workGroups = ivec3(64, 32, 64);
#else
	const ivec3 workGroups = ivec3(8, 4, 8);
#endif

#extension GL_ARB_shader_image_load_store : enable
layout(rgb10_a2) uniform restrict image3D lightFloodfill1;
uniform usampler3D voxelIdsSampler;



// cache for faster reading
shared vec4 cachedFloodfillDatas[10 * 10 * 10];



vec4 getCachedFloodfill(ivec3 offset) {
	ivec3 cachePos = ivec3(gl_LocalInvocationID) + offset + 1; // +1 b/c padding
	return cachedFloodfillDatas[cachePos.x + cachePos.y * 10 + cachePos.z * 100];
}



void main() {
	
	// load shared cache (note: there's more cache slots than threads, so some threads read 2 voxels and others skip)
    int cacheI = int(gl_LocalInvocationIndex);
    if (cacheI < 500) {
		cacheI *= 2;
		ivec3 cachePos = (cacheI / ivec3(1, 10, 100)) % 10;
		cachePos.z *= 2;
		cachePos += ivec3(gl_WorkGroupID * gl_WorkGroupSize) - 1; // -1 b/c padding
		cachePos = clamp(cachePos, ivec3(0), coloredLightingSize - 1);
		cachedFloodfillDatas[cacheI] = imageLoad(lightFloodfill1, cachePos);
		cachePos.z = min(cachePos.z + 1, coloredLightingSize.z - 1);
		cachedFloodfillDatas[cacheI + 1] = imageLoad(lightFloodfill1, cachePos);
	}
	
	// get voxel id and datas
	ivec3 voxelPos = ivec3(gl_GlobalInvocationID);
	uint voxelId = texelFetch(voxelIdsSampler, voxelPos, 0).r;
	#include "/common/voxelDatas.glsl"
	
	// synchronize threads, ensure cache is full
	barrier();
	
	vec4 originalValue = getCachedFloodfill(ivec3(0));
	
}
