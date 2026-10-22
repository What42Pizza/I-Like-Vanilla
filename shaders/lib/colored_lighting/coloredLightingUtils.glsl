#ifndef COLORED_LIGHTING_UTILS
#define COLORED_LIGHTING_UTILS

const ivec3 coloredLightingSize = ivec3(COLORED_LIGHTING_DIST, COLORED_LIGHTING_DIST / 2, COLORED_LIGHTING_DIST);
const ivec3 halfColoredLightingSize = coloredLightingSize / 2;

vec3 cameraDir = vec3(gbufferModelView[0].z, gbufferModelView[1].z, gbufferModelView[2].z);
ivec3 voxelRegionCorner = ivec3(cameraDir * -(halfColoredLightingSize - ivec3(16, 8, 16))) - halfColoredLightingSize;

ivec3 getVoxelPos(vec3 playerPos, vec3 offset, out bool outsideRange) {
	ivec3 voxelPos = ivec3(floor(playerPos + cameraPositionFract + offset)) - voxelRegionCorner;
	outsideRange = any(greaterThanEqual(uvec3(voxelPos), uvec3(coloredLightingSize)));
	return voxelPos;
}

#endif
