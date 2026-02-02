#include "/utils/screen_to_view.glsl"

float sampleCloud(vec3 pos, const bool isNormal) {
	//pos.xz = floor(pos.xz / 16.0) * 16.0;
	float cloudSample = valueNoise((pos - vec3(frameTimeCounter, 0.0, frameTimeCounter) * CLOUD_LAYER_1_SPEED * 0.8) * CLOUD_LAYER_1_SCALE) * CLOUD_LAYER_1_WEIGHT;
	pos.xz -= pos.zx * 0.2;
	cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_2_SPEED * 0.8) * CLOUD_LAYER_2_SCALE) * CLOUD_LAYER_2_WEIGHT;
	cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_3_SPEED * 0.8) * CLOUD_LAYER_3_SCALE) * CLOUD_LAYER_3_WEIGHT;
	if (!isNormal) cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_4_SPEED * 0.8) * CLOUD_LAYER_4_SCALE) * CLOUD_LAYER_4_WEIGHT;
	float sampleWeight = (pos.y - CLOUD_BOTTOM_Y) / (CLOUD_TOP_Y - CLOUD_BOTTOM_Y) * 2.0 - 1.0;
	sampleWeight = sqrt(sqrt(1.0 - sampleWeight * sampleWeight));
	cloudSample = cloudSample / (CLOUD_LAYER_1_WEIGHT + CLOUD_LAYER_2_WEIGHT + CLOUD_LAYER_3_WEIGHT + CLOUD_LAYER_4_WEIGHT) - (1.0 - sampleWeight) * 0.5;
	const float divisor = 1.0 / ((1.0 - REALISTIC_CLOUD_DENSITY) * (1.0 - REALISTIC_CLOUD_DENSITY) + 0.01);
	return clamp((cloudSample - cloudsCoverage) * divisor, 0.0, 1.0);
}



// returns the cloud thinkness and brightness (both inverted) for this pixel
vec2 computeClouds(vec3 playerPos) {
	
	vec3 stepVec = playerPos;
	stepVec.xz /= abs(stepVec.y);
	stepVec.y = sign(stepVec.y);
	
	vec3 pos = cameraPosition;
	float posStartY = clamp(pos.y, CLOUD_BOTTOM_Y, CLOUD_TOP_Y);
	float posEndY = clamp(posStartY + stepVec.y * 1000.0, CLOUD_BOTTOM_Y, CLOUD_TOP_Y);
	//if (posStartY == posEndY) return vec2(1.0, 0.0); // TODO: test if this improve performance
	float maxY = abs(playerPos.y);
	posStartY = clamp(posStartY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	posEndY = clamp(posEndY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	if (posStartY == posEndY) return vec2(1.0, 0.0);
	pos += stepVec * abs(posStartY - pos.y);
	vec3 endPos = pos + stepVec * abs(posEndY - posStartY);
	stepVec = pos - endPos;
	stepVec /= CLOUDS_QUALITY;
	float desnityMult = length(stepVec) * -0.25;
	pos = endPos;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float invThickness = 1.0;
	float invBrightness = 0.0;
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float density = sampleCloud(pos, false);
		float invDensity = exp(density * desnityMult);
		float sampleUp = sampleCloud(pos + cloudsShadowcasterDir, true);
		invThickness *= invDensity;
		invBrightness = mix(invBrightness, sampleUp, 1.0 - sqrt(invDensity));
		pos += stepVec;
	}
	
	return vec2(invThickness, invBrightness);
}
