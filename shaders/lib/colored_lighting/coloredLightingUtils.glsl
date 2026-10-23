#ifndef COLORED_LIGHTING_UTILS
#define COLORED_LIGHTING_UTILS

const ivec3 coloredLightingSize = ivec3(COLORED_LIGHTING_DIST, COLORED_LIGHTING_DIST / 2, COLORED_LIGHTING_DIST);
const ivec3 halfColoredLightingSize = coloredLightingSize / 2;

vec3 cameraDir = vec3(gbufferModelView[0].z, gbufferModelView[1].z, gbufferModelView[2].z);
ivec3 voxelRegionCorner = ivec3(cameraDir * -(halfColoredLightingSize - ivec3(16, 8, 16))) - halfColoredLightingSize;
vec3 prevCameraDir = vec3(gbufferPreviousModelView[0].z, gbufferPreviousModelView[1].z, gbufferPreviousModelView[2].z);
ivec3 prevVoxelRegionCorner = ivec3(prevCameraDir * -(halfColoredLightingSize - ivec3(16, 8, 16))) - halfColoredLightingSize;

vec3 getVoxelPos(vec3 playerPos, vec3 offset, out bool outsideRange) {
	vec3 voxelPos = playerPos + cameraPositionFract + offset - voxelRegionCorner;
	outsideRange = any(greaterThanEqual(uvec3(floor(voxelPos)), uvec3(coloredLightingSize)));
	return voxelPos;
}

#endif
