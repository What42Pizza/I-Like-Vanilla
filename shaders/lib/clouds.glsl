#ifdef FIRST_PASS
	const int quality = 12;
	const float lowThreshold = 0.3;
	const float highThreshold = 0.35;
	const float startY = 150.0;
	const float endY = 200.0;
	const float yFadeSlope = 0.05;
#endif



#include "/utils/screen_to_view.glsl"

float sampleCloud(vec3 pos, const bool detailed  ARGS_OUT) {
	pos.y *= 2.0;
	float sample = simplexNoise(pos.xz * 0.005);
	sample += simplexNoise(pos.xz * 0.06) * 0.2;
	if (detailed) sample += simplexNoise(pos * 0.04) * 0.2;
	sample = clamp((sample - lowThreshold) / (highThreshold - lowThreshold), 0.0, 1.0);
	pos.y /= 2.0;
	sample *= clamp(yFadeSlope * (endY - startY) / 2.0 - yFadeSlope * abs(pos.y - (startY + endY) / 2.0), 0.0, 1.0);
	return sample;
}



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
	float maxY = abs(playerPos.y);
	
	#include "/import/cameraPosition.glsl"
	vec3 pos = cameraPosition;
	float posStartY = clamp(pos.y, startY, endY);
	float posEndY = clamp(posStartY + stepVec.y * 1000.0, startY, endY);
	posStartY = clamp(posStartY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	posEndY = clamp(posEndY - cameraPosition.y, -maxY, maxY) + cameraPosition.y;
	if (posStartY == posEndY) return;
	pos += stepVec * abs(posStartY - pos.y);
	vec3 endPos = pos + stepVec * abs(posEndY - posStartY);
	stepVec = endPos - pos;
	float dist = length(stepVec);
	pos = endPos;
	stepVec = -stepVec;
	stepVec /= quality;
	
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	pos += stepVec * (dither - 0.5);
	
	float finalMult = 0.7 + 0.3 * (1.0 - 48.0 / (48.0 + dist)) - 0.02;
	float sampleMult = pow(finalMult, quality);
	
	for (int i = 0; i < quality; i++) {
		float sample = sampleCloud(pos, true  ARGS_IN);
		float brightness = (pos.y - startY) / (endY - startY);
		brightness = 1.0 - (1.0 - brightness) * (1.0 - brightness);
		color = mix(color, vec3(0.6 + 0.4 * brightness), sample * sampleMult);
		pos += stepVec;
	}
	
}
