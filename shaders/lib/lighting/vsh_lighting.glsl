void doVshLighting(inout vec2 lmcoord, inout vec3 glcolor, vec3 viewPos, vec3 normal, vec3 worldNormal) {
	
	//lmcoord.y = (lmcoord.y * lmcoord.y + lmcoord.y) * 0.5; // kinda like squaring but not as intense
	
	#if HANDHELD_LIGHT_ENABLED == 1 && SHOW_DANGEROUS_LIGHT == 0
		float viewPosLen = length(viewPos);
		if (viewPosLen <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - viewPosLen / HANDHELD_LIGHT_DISTANCE, 0.0);
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			float lightDot = -dot(normalize(viewPos), normal);
			handLightBrightness *= (lightDot - 1.0) * HANDHELD_LIGHT_REALISM + 1.0;
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	vec3 normalForSS = worldNormal;
	// +-1.0x: -0.4
	// +-1.0z: -0.0
	// +1.0y: +0.325
	// -1.0y: -0.65
	normalForSS.xz = abs(normalForSS.xz);
	#if defined SHADER_GBUFFERS_HAND || defined SHADER_GBUFFERS_HAND_WATER
		normalForSS.xz = normalForSS.zx;
	#endif
	normalForSS.y *= sign(normalForSS.y) * -0.25 + 0.75; // -1: *1, 1: *0.5
	float sideShading = dot(normalForSS, vec3(-0.4, 0.65, 0.0));
	float brightForSS = max(lmcoord.x, lmcoord.y);
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, brightForSS * brightForSS) * 0.8;
	sideShading *= 1.0 - step(1.0, lmcoord.x) * 0.6;
	glcolor *= 1.0 + sideShading + step(1.0, lmcoord.x) * 0.125;
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		lmcoord.x *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT * 0.1;
	#endif
	
	lmcoord *= 1.0 - 0.2 * darknessFactor;
	lmcoord = max(lmcoord - 1.5 * darknessLightFactor, 0.0);
	
}
