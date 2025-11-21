#include "/utils/screen_to_view.glsl"

float sampleNetherCloud(vec3 pos) {
	pos *= 0.333;
	pos.y *= 0.25;
	float cloudSample = valueNoise3((pos + frameTimeCounter * 0.125)) * 1.0;
	cloudSample += valueNoise3((pos + frameTimeCounter * 0.0625) * 0.5) * 0.5;
	cloudSample += valueNoise3((pos + frameTimeCounter * 0.03125) * 0.25) * 0.25;
	cloudSample = cloudSample / (1.0 + 0.5 + 0.25);
	return clamp((cloudSample - (1.0 - NETHER_CLOUDS_CONVERAGE)) * 6.0, 0.0, 1.0);
}



// returns the cloud thinkness and brightness (both inverted) for this pixel
vec2 computeNetherClouds(vec3 playerPos) {
	vec3 endPos = playerPos + cameraPosition;
	vec3 pos = cameraPosition;
	vec3 stepVec = (endPos - pos);
	float desnityMult = length(stepVec) * -0.25;
	stepVec /= CLOUDS_QUALITY;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float invThickness = 1.0;
	float invBrightness = 0.0;
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float density = sampleNetherCloud(pos);
		float invDensity = exp(density * desnityMult);
		invThickness *= invDensity;
		invBrightness = mix(invBrightness, density, 1.0 - invDensity);
		pos += stepVec;
	}
	
	return vec2(invThickness, invBrightness);
}
