#include "/utils/projections.glsl"

float sampleNetherCloud(vec3 pos) {
	pos *= 0.002 / NETHER_CLOUDS_SCALE;
	pos.y *= 0.33;
	float cloudSample = 0.0;
	cloudSample += texNoise3D((pos + frameTimeCounter*0 / 1024.0) * 1.0) * 1.0;
	cloudSample += texNoise3D((pos + frameTimeCounter*0 / 2048.0) * 0.5) * 0.5;
	cloudSample /= 1.0 + 0.5;
	
	return percentThrough(cloudSample, 1.0 - NETHER_CLOUDS_COVERAGE * 0.75, 1.0);
}



// returns the cloud thickness and brightness (both inverted) for this pixel
vec2 computeNetherClouds(vec3 playerPos) {
	
	float len = length(playerPos);
	playerPos /= len;
	len = min(len, clamp(far, 16.0 * 6.0, 16.0 * 12.0));
	playerPos *= len;
	
	float densityMult = length(playerPos) * NETHER_CLOUDS_DENSITY * -2.0 / CLOUDS_QUALITY;
	
	ivec2 noisePos = ivec2(gl_FragCoord.xy) + ivec2(frameCounter * 31, frameCounter * 34);
	float noise = texelFetch(noisetex, noisePos & 127, 0).b;
	
	float invThickness = 1.0;
	float invBrightness = 0.0;
	for (int i = CLOUDS_QUALITY; i >= 0; i--) {
		float j = float(i) / CLOUDS_QUALITY;
		j = 1.0 - sqrt(1.0 - j) + noise / CLOUDS_QUALITY * 2.0;
		vec3 pos = cameraPosition + playerPos * j;
		float density = sampleNetherCloud(pos);
		float invDensity = exp(density * densityMult);
		invThickness *= invDensity;
		invBrightness = mix(invBrightness, density, 1.0 - invDensity);
	}
	
	return vec2(invThickness, invBrightness);
}
