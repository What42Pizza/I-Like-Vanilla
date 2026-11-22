#ifndef SAMPLE_COLORED_LIGHTING
#define SAMPLE_COLORED_LIGHTING

#include "/lib/colored_lighting/coloredLightingUtils.glsl"

vec3 sampleColoredLighting(vec3 voxelPos) {
	if (frameCounter % 2 == 0) {
		return texture(lightFloodfill2Sampler, vec3(voxelPos) / coloredLightingSize, 0).rgb;
	} else {
		return texture(lightFloodfill1Sampler, vec3(voxelPos) / coloredLightingSize, 0).rgb;
	}
}

#endif
