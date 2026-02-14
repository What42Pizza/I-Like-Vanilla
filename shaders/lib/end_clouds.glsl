#include "/utils/screen_to_view.glsl"

float sampleEndCloud(vec3 pos) {
	pos.x += pos.y * pos.y * (1.0 / 128.0);
	pos.y += pos.z * pos.z * (1.0 / 128.0);
	pos.z += pos.x * pos.x * (1.0 / 128.0);
	pos *= 0.25 / END_CLOUDS_SCALE;
	pos.y *= 2.0;
	float cloudSample = 0.0;
	cloudSample += valueNoise((pos + frameTimeCounter * 0.125 * 0.125  ) * 1.0 ) * 1.0 ;
	cloudSample += valueNoise((pos + frameTimeCounter * 0.125 * 0.0625 ) * 0.5 ) * 0.5 ;
	cloudSample += valueNoise((pos + frameTimeCounter * 0.125 * 0.03125) * 0.25) * 0.25;
	cloudSample /= 1.0 + 0.5 + 0.25;
	cloudSample = (cloudSample - (1.0 - END_CLOUDS_COVERAGE * 0.75)) / END_CLOUDS_COVERAGE * 0.75;
	return clamp(cloudSample, 0.0, 1.0);
}



// returns the cloud thickness (inverted) and brightness for this pixel
vec2 computeEndClouds(vec3 playerPos) {
	vec3 pos = cameraPosition + playerPos; // start at the block and move towards the camera
	vec3 endPos = cameraPosition;
	vec3 stepVec = endPos - pos;
	float densityMult = length(stepVec) * -0.03125;
	stepVec /= CLOUDS_QUALITY;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float invThickness = 1.0;
	float brightness = 0.0;
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float density = sampleEndCloud(pos);
		density = 1.0 - (1.0 - density) * (1.0 - density);
		float invDensity = exp(density * densityMult);
		invThickness *= invDensity;
		brightness *= invDensity;
		brightness += density * density;
		pos += stepVec;
	}
	invThickness = 1.0 - (1.0 - invThickness) * (1.0 - invThickness);
	brightness = min(brightness, 1.0);
	
	return vec2(invThickness, brightness);
}
