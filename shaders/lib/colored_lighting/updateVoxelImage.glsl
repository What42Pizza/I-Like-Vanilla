#include "/lib/colored_lighting/coloredLightingUtils.glsl"



void updateVoxelImage(vec3 playerPos, uint materialId) {
	
	if (!any(equal(ivec4(renderStage), ivec4(
		MC_RENDER_STAGE_TERRAIN_SOLID,
		MC_RENDER_STAGE_TERRAIN_TRANSLUCENT,
		MC_RENDER_STAGE_TERRAIN_CUTOUT,
		MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED
	)))) return;
	
	bool outsideRange;
	ivec3 voxelPos = getVoxelPos();
	vec3 playerBlockPos = playerPos + cameraPositionFract + at_midBlock / 64.0;
	if (any(lessThan(playerBlockPos, -halfColoredLightingSize)) || any(greaterThanEqual(voxelPos, coloredLightingSize))) return;
	
	ivec3 voxelPos = ivec3(blockPos) + coloredLightingSize / 2;
	
	uint voxelId;
	#define GET_VOXEL_ID
	#include "/common/blockDatas.glsl"
	
	if (voxelId == 0u) return;
	
	imageStore(lightVoxels, ivec3(voxelPos), uvec4(voxelId, 0u, 0u, 0u));
	
}
