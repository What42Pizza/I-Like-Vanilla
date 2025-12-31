#include "/lib/colored_lighting/coloredLightingUtils.glsl"

#extension GL_ARB_shader_image_load_store : enable
writeonly uniform image3D voxelIds;



void updateVoxelIds(vec3 playerPos, uint materialId) {
	
	if (!any(equal(ivec4(renderStage), ivec4(
		MC_RENDER_STAGE_TERRAIN_SOLID,
		MC_RENDER_STAGE_TERRAIN_TRANSLUCENT,
		MC_RENDER_STAGE_TERRAIN_CUTOUT,
		MC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED
	)))) return;
	
	bool outsideRange;
	ivec3 voxelPos = getVoxelPos(playerPos, at_midBlock / 64.0, outsideRange);
	if (outsideRange) return;
	
	uint voxelId;
	#define GET_VOXEL_ID
	#include "/common/blockDatas.glsl"
	
	if (voxelId == 0u) return;
	
	imageStore(voxelIds, ivec3(voxelPos), uvec4(voxelId, 0u, 0u, 0u));
	
}
