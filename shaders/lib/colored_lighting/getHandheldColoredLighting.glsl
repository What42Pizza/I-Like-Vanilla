vec3 getEmissionForItemId(int itemId) {
	
	uint encodedData = uint(max(itemId, 0));
	encodedData *= uint((encodedData & (1u << 14u)) > 0u && encodedData != 65535u);
	uint materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	uint voxelId = 0u;
	#define GET_VOXEL_ID
	#include "/generated/blockDatas.glsl"
	
	vec3 emission;
	#define GET_EMISSION
	#include "/generated/voxelDatas.glsl"
	if (voxelId == 0u) emission = vec3(0.0);
	if (voxelId == 1u) emission = vec3(0.0);
	emission = mix(vec3(getLum(emission)), emission, COLORED_LIGHTING_SATURATION);
	
	return emission;
}



vec3 getHandheldColoredLighting(vec3 viewPos) {
	vec3 rightEmission = getEmissionForItemId(heldItemId);
	vec3 leftEmission = getEmissionForItemId(heldItemId2);
	vec3 emission = max(rightEmission, leftEmission);
	
	float handLightBrightness = max(1.0 - length(viewPos) / HANDHELD_LIGHT_DISTANCE, 0.0);
	handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
	emission *= handLightBrightness;
	
	return emission;
}
