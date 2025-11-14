void toVoxelImage(vec3 playerPos, uint materialId) {
	int voxelId = 1;
	#define SET_VOXEL_ID
	#include "/blockDatas.glsl"
	if (voxelId == 0) return;
	vec3 blockPos = playerPos + cameraPosition + at_midBlock / 64.0;
	
}
