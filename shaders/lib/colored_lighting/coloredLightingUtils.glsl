#ifndef COLORED_LIGHTING_UTILS
#define COLORED_LIGHTING_UTILS

const ivec3 coloredLightingSize = ivec3(COLORED_LIGHTING_DIST, COLORED_LIGHTING_DIST / 2, COLORED_LIGHTING_DIST);
const ivec3 halfColoredLightingSize = coloredLightingSize / 2;

ivec3 getVoxelPos(vec3 playerPos, vec3 offset, out bool outsideRange) {
	vec3 playerBlockPos = playerPos + cameraPositionFract + offset;
	ivec3 voxelPos = ivec3(floor(playerBlockPos)) + halfColoredLightingSize;
	outsideRange = any(lessThan(voxelPos, ivec3(0))) || any(greaterThanEqual(voxelPos, coloredLightingSize));
	return ((voxelPos + cameraPositionInt) % coloredLightingSize + coloredLightingSize) % coloredLightingSize;
}

#endif
