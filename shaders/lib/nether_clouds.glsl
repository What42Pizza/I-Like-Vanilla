#include "/utils/screen_to_view.glsl"

float sampleNetherCloud(vec3 pos) {
	pos *= 0.25 / NETHER_CLOUDS_SCALE;
	pos.y *= 0.5;
	float cloudSample = 0.0;
	cloudSample += valueNoise3((pos + frameTimeCounter * 0.125  ) * 1.0 ) * 1.0 ;
	cloudSample += valueNoise3((pos + frameTimeCounter * 0.0625 ) * 0.5 ) * 0.75;
	cloudSample += valueNoise3((pos + frameTimeCounter * 0.03125) * 0.25) * 0.5 ;
	cloudSample /= 1.0 + 0.75 + 0.5;
	return clamp(cloudSample - (1.0 - NETHER_CLOUDS_COVERAGE * 0.5), 0.0, 1.0);
}



// returns the cloud thinkness and brightness (both inverted) for this pixel
vec2 computeNetherClouds(vec3 playerPos) {
	vec3 pos = cameraPosition + playerPos; // start at the block and move towards the camera
	vec3 endPos = cameraPosition;
	vec3 stepVec = endPos - pos;
	float densityMult = length(stepVec) * -0.2;
	stepVec /= CLOUDS_QUALITY;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float invThickness = 1.0;
	float invBrightness = 0.0;
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float density = sampleNetherCloud(pos);
		float invDensity = exp(density * densityMult);
		invThickness *= invDensity;
		invBrightness = mix(invBrightness, density, 1.0 - invDensity);
		pos += stepVec;
	}
	invThickness = 1.0 - (1.0 - invThickness) * (1.0 - invThickness);
	
	return vec2(invThickness, invBrightness);
}
