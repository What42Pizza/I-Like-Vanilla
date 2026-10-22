#include "/lib/colored_lighting/coloredLightingUtils.glsl"

#extension GL_ARB_shader_image_load_store : enable
layout(r8ui) uniform writeonly uimage3D voxelIds;



void updateVoxelIds(vec3 playerPos, uint encodedBlockData, uint materialId) {
	
	bool outsideRange;
	ivec3 voxelPos = getVoxelPos(playerPos, at_midBlock / 64.0, outsideRange);
	if (outsideRange) return;
	
	// assume voxel id
	bool excludeFromShadows = (encodedBlockData & (3u << 12u)) >= (1u << 12u); // test if 'shadow casting' value is 1 or 3
	uint voxelId = uint(
		abs(gl_Normal.x + gl_Normal.y + gl_Normal.z) == 1.0 // assume solid if normal is non-diagonal
		&& !excludeFromShadows // is not solid if it does 
	);
	
	// get specific block id
	#define GET_VOXEL_ID
	#include "/generated/blockDatas.glsl"
	
	if (voxelId == 0u) return;
	
	imageStore(voxelIds, ivec3(voxelPos), uvec4(voxelId, 0u, 0u, 0u));
	
}
