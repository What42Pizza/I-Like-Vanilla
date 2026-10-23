#ifndef SAMPLE_COLORED_LIGHTING
#define SAMPLE_COLORED_LIGHTING

#include "/lib/colored_lighting/coloredLightingUtils.glsl"

vec3 sampleColoredLighting(vec3 voxelPos) {
	if (frameCounter % 2 == 0) {
		vec4 value = texture(lightFloodfill2Sampler, vec3(voxelPos) / coloredLightingSize, 0);
		return value.rgb / value.w;
	} else {
		vec4 value = texture(lightFloodfill1Sampler, vec3(voxelPos) / coloredLightingSize, 0);
		return value.rgb / value.w;
	}
}

#endif
