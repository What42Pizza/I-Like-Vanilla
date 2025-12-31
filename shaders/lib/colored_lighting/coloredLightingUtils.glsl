#ifndef COLORED_LIGHTING_UTILS
#define COLORED_LIGHTING_UTILS

const ivec3 coloredLightingSize = ivec3(COLORED_LIGHTING_DIST, COLORED_LIGHTING_DIST / 2, COLORED_LIGHTING_DIST);
const ivec3 halfColoredLightingSize = ivec3(COLORED_LIGHTING_DIST, COLORED_LIGHTING_DIST / 2, COLORED_LIGHTING_DIST);

ivec3 getVoxelPos(vec3 playerPos, out bool outsideRange) {
	vec3 playerBlockPos = playerPos + cameraPositionFract + at_midBlock / 64.0;
	outsideRange = any(lessThan(playerBlockPos, -halfColoredLightingSize)) || any(greaterThanEqual(voxelPos, halfColoredLightingSize));
	return (ivec3(playerBlockPos) % coloredLightingSize + coloredLightingSize) % coloredLightingSize;
}

#endif
