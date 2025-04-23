#ifdef FIRST_PASS
	varying vec3 brightCloudColor;
	varying vec3 darkCloudColor;
#endif





#ifdef FSH



#ifdef FIRST_PASS
	
	float valueHash(vec3 p) {
		return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
	}
	
	float valueNoise(vec3 v) {
		vec3 i = floor(v);
		vec3 f = fract(v);
		
		float lll = valueHash(i);
		float llh = valueHash(i + vec3(0.0, 0.0, 1.0));
		float lhl = valueHash(i + vec3(0.0, 1.0, 0.0));
		float lhh = valueHash(i + vec3(0.0, 1.0, 1.0));
		float hll = valueHash(i + vec3(1.0, 0.0, 0.0));
		float hlh = valueHash(i + vec3(1.0, 0.0, 1.0));
		float hhl = valueHash(i + vec3(1.0, 1.0, 0.0));
		float hhh = valueHash(i + vec3(1.0, 1.0, 1.0));
		
		vec3 u = f * f * (3.0 - 2.0 * f);
		float ll = mix(lll, llh, u.z);
		float lh = mix(lhl, lhh, u.z);
		float hl = mix(hll, hlh, u.z);
		float hh = mix(hhl, hhh, u.z);
		float l = mix(ll, lh, u.y);
		float h = mix(hl, hh, u.y);
		return mix(l, h, u.x);
	}
	
#endif

#include "/utils/screen_to_view.glsl"

float sampleCloud(vec3 pos, float coverage, const bool isNormal  ARGS_OUT) {
	pos.xz -= pos.zx * 0.15;
	//pos.xz = floor(pos.xz / 16.0) * 16.0;
	#include "/import/frameTimeCounter.glsl"
	float sample = valueNoise((pos - vec3(frameTimeCounter, 0.0, frameTimeCounter) * CLOUD_LAYER_1_SPEED * 0.8) * CLOUD_LAYER_1_SCALE) * CLOUD_LAYER_1_WEIGHT;
	sample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_2_SPEED * 0.8) * CLOUD_LAYER_2_SCALE) * CLOUD_LAYER_2_WEIGHT;
	sample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_3_SPEED * 0.8) * CLOUD_LAYER_3_SCALE) * CLOUD_LAYER_3_WEIGHT;
	if (!isNormal) sample += valueNoise((pos - frameTimeCounter * CLOUD_LAYER_4_SPEED * 0.8) * CLOUD_LAYER_4_SCALE) * CLOUD_LAYER_4_WEIGHT;
	float sampleWeight = (pos.y - CLOUD_BOTTOM_Y) / (CLOUD_TOP_Y - CLOUD_BOTTOM_Y) * 2.0 - 1.0;
	sampleWeight = sqrt(sqrt(1.0 - sampleWeight * sampleWeight));
	sample = sample / (CLOUD_LAYER_1_WEIGHT + CLOUD_LAYER_2_WEIGHT + CLOUD_LAYER_3_WEIGHT + CLOUD_LAYER_4_WEIGHT) - (1.0 - sampleWeight) * 0.5;
	const float divisor = 1.0 / ((1.0 - REALISTIC_CLOUD_DENSITY) * (1.0 - REALISTIC_CLOUD_DENSITY) + 0.01);
	return clamp((sample - coverage) * divisor, 0.0, 1.0);
}



#include "/utils/getCloudColor.glsl"

void renderClouds(inout vec3 color  ARGS_OUT) {
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 screenPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 screenPosDh = screenToViewDh(vec3(texcoord, dhDepth)  ARGS_IN);
		if (dot(screenPosDh, screenPosDh) < dot(screenPos, screenPos)) screenPos = screenPosDh;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = mat3(gbufferModelViewInverse) * screenPos;
	
	vec3 stepVec = playerPos;
	stepVec.xz /= abs(stepVec.y);
	stepVec.y = sign(stepVec.y);
	
	#include "/import/cameraPosition.glsl"
	vec3 pos = cameraPosition;
	float posStartY = clamp(pos.y, CLOUD_BOTTOM_Y, CLOUD_TOP_Y);
	float posEndY = clamp(posStartY + stepVec.y * 1000.0, CLOUD_BOTTOM_Y, CLOUD_TOP_Y);
	float maxY = abs(playerPos.y);
	posStartY = clamp(posStartY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	posEndY = clamp(posEndY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	if (posStartY == posEndY) return;
	pos += stepVec * abs(posStartY - pos.y);
	vec3 endPos = pos + stepVec * abs(posEndY - posStartY);
	stepVec = pos - endPos;
	float dist = length(stepVec);
	stepVec /= CLOUDS_QUALITY;
	pos = endPos;
	
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float mixMult = 0.8 + 0.2 * (1.0 - CLOUD_OPACITY_DISTANCE / (dist + CLOUD_OPACITY_DISTANCE)) - 0.02;
	mixMult *= 1.0 - 0.1 * REALISTIC_CLOUD_TRANSPARENCY;
	mixMult = pow(mixMult, CLOUDS_QUALITY);
	
	#include "/import/shadowLightPosition.glsl"
	vec3 shadowcasterDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition) * 10.0;
	#include "/import/rainStrength.glsl"
	float coverage = mix(1.0 - CLOUD_COVERAGE, 0.8 - 0.6 * CLOUD_WEATHER_COVERAGE, rainStrength);
	for (int i = 0; i < CLOUDS_QUALITY; i++) {
		float sample = sampleCloud(pos, coverage, false  ARGS_IN);
		if (sample > 0.0) sample = 0.5 + 0.5 * sample;
		float sampleUp = sampleCloud(pos + shadowcasterDir, coverage, true  ARGS_IN);
		vec3 cloudColor = getCloudColor(1.0 - 0.25 * sampleUp  ARGS_IN);
		color = mix(color, cloudColor, sample * mixMult);
		pos += stepVec;
	}
	
}



#endif





#ifdef VSH



void prepareClouds(ARG_OUT) {
	brightCloudColor = vec3(1.0);
	darkCloudColor = vec3(0.8, 0.85, 0.95);
}



#endif
