#include "/utils/projections.glsl"


#if CLOUDS_TYPE == 3
	vec2 roundCloud(vec2 pos, float radius) {
		vec2 corner = round(pos);
		vec2 offset = pos - corner;
		vec2 newOffset = smoothstep(-radius, radius, offset) - 0.5;
		return corner + newOffset;
	}

	float sampleCloud(vec3 pos3D, const bool _isSimplified) {
		vec2 pos = pos3D.xz;
		pos.x += cloudTime;          // TODO: configurable speed
		pos /= 12.0;                 // TODO: configurable scale
		pos = roundCloud(pos, 0.25); // TODO: configurable rounding
		vec2 uv = pos / textureSize(CLOUDS_TEXTURE, 0);
		float sample = texture2D(CLOUDS_TEXTURE, uv).a;
		return round(sample);
	}
#endif



#if CLOUDS_TYPE == 4
	float sampleCloud(vec3 pos, const bool isSimplified) {
		//pos.xz = floor(pos.xz / 24.0) * 24.0;
		float cloudSample = valueNoise((pos - vec3(frameTimeCounter, 0.0, frameTimeCounter) * CLOUD_LAYER_1_SPEED * 0.8) * CLOUD_LAYER_1_SCALE) * CLOUD_LAYER_1_WEIGHT;
		pos.xz -= pos.zx * 0.2;
		cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_2_SPEED * 0.8) * CLOUD_LAYER_2_SCALE) * CLOUD_LAYER_2_WEIGHT;
		cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_3_SPEED * 0.8) * CLOUD_LAYER_3_SCALE) * CLOUD_LAYER_3_WEIGHT;
		if (!isSimplified) cloudSample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_4_SPEED * 0.8) * CLOUD_LAYER_4_SCALE) * CLOUD_LAYER_4_WEIGHT;
		float sampleWeight = (pos.y - REALISTIC_CLOUDS_BOTTOM_Y) / (REALISTIC_CLOUDS_TOP_Y - REALISTIC_CLOUDS_BOTTOM_Y) * 2.0 - 1.0;
		sampleWeight = sqrt(sqrt(1.0 - sampleWeight * sampleWeight));
		cloudSample = cloudSample / (CLOUD_LAYER_1_WEIGHT + CLOUD_LAYER_2_WEIGHT + CLOUD_LAYER_3_WEIGHT + CLOUD_LAYER_4_WEIGHT) - (1.0 - sampleWeight) * 0.5;
		const float divisor = 1.0 / ((1.0 - REALISTIC_CLOUDS_DENSITY) * (1.0 - REALISTIC_CLOUDS_DENSITY) + 0.01);
		return clamp((cloudSample - cloudsCoverage) * divisor, 0.0, 1.0);
	}
#endif



// returns the cloud thickness and brightness (both inverted) for this pixel
vec2 computeClouds(vec3 playerPos, bool isSky) {
	
	#if CLOUDS_TYPE == 4
		float playerLen = length(playerPos.xz);
		playerPos /= playerLen;
		float distLimitAmount = sampleCloud(cameraPosition + normalize(playerPos) * 20.0, true);
		distLimitAmount = 1.0 - (1.0 - distLimitAmount) * (1.0 - distLimitAmount) * (1.0 - distLimitAmount);
		playerPos *= min(playerLen, mix(128 * 16.0, 20 * 16.0, distLimitAmount));
	#endif
	
	vec3 stepVec = playerPos;
	stepVec.xz /= abs(stepVec.y);
	stepVec.y = sign(stepVec.y);
	
	#if CLOUDS_TYPE == 3
		#define CLOUDS_TOP_Y (VOL_VANILLA_CLOUDS_MIDDLE + VOL_VANILLA_CLOUDS_THICKNESS * 0.5)
		#define CLOUDS_BOTTOM_Y (VOL_VANILLA_CLOUDS_MIDDLE - VOL_VANILLA_CLOUDS_THICKNESS * 0.5)
	#elif CLOUDS_TYPE == 4
		#define CLOUDS_TOP_Y REALISTIC_CLOUDS_TOP_Y
		#define CLOUDS_BOTTOM_Y REALISTIC_CLOUDS_BOTTOM_Y
	#endif
	
	vec3 pos = cameraPosition;
	float posStartY = clamp(pos.y, CLOUDS_BOTTOM_Y, CLOUDS_TOP_Y);
	float posEndY = clamp(posStartY + stepVec.y * 1000.0, CLOUDS_BOTTOM_Y, CLOUDS_TOP_Y);
	//if (posStartY == posEndY) return vec2(1.0, 0.0); // TODO: test if this improve performance
	if (!isSky) {
		float maxY = abs(playerPos.y);
		posStartY = clamp(posStartY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
		posEndY = clamp(posEndY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	}
	if (posStartY == posEndY) return vec2(1.0, 0.0);
	pos += stepVec * abs(posStartY - pos.y);

	#ifdef CLOUD_BORDER_FOG_ENABLED
		vec3 cloudPos = pos - cameraPosition;
		float cloudDistance = getBorderFogDistance(cloudPos / CLOUD_BORDER_FOG_SCALE);
		if (cloudDistance > BORDER_FOG_END) return vec2(1.0, 0.0);
	#endif

	vec3 endPos = pos + stepVec * abs(posEndY - posStartY);
	stepVec = pos - endPos;
	stepVec /= CLOUDS_QUALITY;
	float densityMult = length(stepVec) * -0.25;
	pos = endPos;
	
	float dither = bayer64(gl_FragCoord.xy);
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	#if CLOUDS_TYPE == 3
		densityMult *= VOL_VANILLA_CLOUDS_DENSITY;
		vec3 cloudsShadowcasterDir = cloudsShadowcasterDir * dither * 2.0;
	#endif
	
	float invThickness = 1.0;
	float invBrightness = 0.0;
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float density = sampleCloud(pos, false);
		float invDensity = exp(density * densityMult);
		float sampleUp = sampleCloud(pos + cloudsShadowcasterDir, true);
		invThickness *= invDensity;
		invBrightness = mix(invBrightness, sampleUp, 1.0 - sqrt(invDensity));
		pos += stepVec;
	}
	
	return vec2(invThickness, invBrightness);
}
