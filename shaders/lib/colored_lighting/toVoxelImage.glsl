void toVoxelImage(vec3 playerPos, uint materialId) {
	uint voxelId = 1u;
	#define GET_VOXEL_ID
	#include "/common/blockDatas.glsl"
	if (voxelId == 0u) return;
	vec3 blockPos = playerPos + cameraPosition + at_midBlock / 64.0;
	
}
