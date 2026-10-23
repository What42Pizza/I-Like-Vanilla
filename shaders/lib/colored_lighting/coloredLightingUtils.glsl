#ifndef COLORED_LIGHTING_UTILS
#define COLORED_LIGHTING_UTILS

#if COLORED_LIGHTING_DIST == 32
	const ivec3 coloredLightingSize = ivec3(32, 24, 32);
#elif COLORED_LIGHTING_DIST == 48
	const ivec3 coloredLightingSize = ivec3(48, 32, 48);
#elif COLORED_LIGHTING_DIST == 64
	const ivec3 coloredLightingSize = ivec3(64, 48, 64);
#elif COLORED_LIGHTING_DIST == 96
	const ivec3 coloredLightingSize = ivec3(96, 72, 96);
#elif COLORED_LIGHTING_DIST == 128
	const ivec3 coloredLightingSize = ivec3(128, 96, 128);
#elif COLORED_LIGHTING_DIST == 192
	const ivec3 coloredLightingSize = ivec3(192, 144, 192);
#elif COLORED_LIGHTING_DIST == 256
	const ivec3 coloredLightingSize = ivec3(256, 192, 256);
#elif COLORED_LIGHTING_DIST == 384
	const ivec3 coloredLightingSize = ivec3(384, 261, 384);
#elif COLORED_LIGHTING_DIST == 512
	const ivec3 coloredLightingSize = ivec3(512, 348, 512);
#endif
const ivec3 halfColoredLightingSize = coloredLightingSize / 2;

vec3 cameraDir = vec3(gbufferModelView[0].z, gbufferModelView[1].z, gbufferModelView[2].z);
ivec3 voxelRegionCorner = ivec3(cameraDir * -(halfColoredLightingSize - ivec3(16, 8, 16))) - halfColoredLightingSize;
vec3 prevCameraDir = vec3(gbufferPreviousModelView[0].z, gbufferPreviousModelView[1].z, gbufferPreviousModelView[2].z);
ivec3 prevVoxelRegionCorner = ivec3(prevCameraDir * -(halfColoredLightingSize - ivec3(16, 8, 16))) - halfColoredLightingSize;

vec3 getVoxelPos(vec3 playerPos, vec3 offset, out bool outsideRange) {
	vec3 voxelPos = playerPos + cameraPositionFract + offset - voxelRegionCorner;
	outsideRange = any(lessThan(voxelPos, vec3(0.0))) || any(greaterThanEqual(voxelPos, vec3(coloredLightingSize)));
	return voxelPos;
}

#endif
