vec3 getDistortedShadowPos(vec3 shadowPos  ARGS_OUT) {
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



float getVolSunraysAmount(vec3 playerPos, float distMult  ARGS_OUT) {
	
	float blockDepth = length(playerPos);
	vec3 playerPosStep = normalize(playerPos) * (blockDepth / SUNRAYS_QUALITY);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, vec3(0.0)));
	vec3 nextShadowPos = transform(shadowProjection, transform(shadowModelView, playerPosStep));
	vec3 shadowPosStep = nextShadowPos - shadowPos;
	
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	
	// good values: 21.0015, 22.001, 0.02
	#ifdef GRADIENT_NOISE_SPEED
		#undef GRADIENT_NOISE_SPEED
	#endif
	#define GRADIENT_NOISE_SPEED 21.0015
	#include "/utils/var_gradient_noise.glsl"
	
	shadowPos += shadowPosStep * (noise - 0.0);
	
	float total = 0.0;
	for (int i = 0; i < SUNRAYS_QUALITY; i ++) {
		
		vec3 distortedShadowPos = getDistortedShadowPos(shadowPos  ARGS_IN);
		float diff = texelFetch(shadowtex0, ivec2(distortedShadowPos.xy * shadowMapResolution), 0).r - distortedShadowPos.z;
		if (diff > 0.0) {
			total += 1.0;
		} else {
			total *= 1.0 + diff;
		}
		
		shadowPos += shadowPosStep;
		
	}
	float sunraysAmount = total / SUNRAYS_QUALITY;
	sunraysAmount *= sunraysAmount;
	sunraysAmount *= blockDepth * distMult;
	
	float dx = dFdx(sunraysAmount);
	if ((int(gl_FragCoord.x) & 1) == 1) dx = -dx;
	sunraysAmount += dx * 0.25;
	float dy = dFdy(sunraysAmount);
	if ((int(gl_FragCoord.y) & 1) == 1) dy = -dy;
	sunraysAmount += dy * 0.25;
	
	#include "/import/eyeBrightnessSmooth.glsl"
	float skyBrightness = eyeBrightnessSmooth.y / 240.0;
	float amountMin = mix(SUNRAYS_MIN_UNDERGROUND, SUNRAYS_MIN_SURFACE, skyBrightness * skyBrightness);
	vec2 blockLmCoords = unpackVec2(texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0).x);
	sunraysAmount += (sunraysAmount > 0.0 ? 1.0 : 0.0) * amountMin * (0.3 + 1.5 * blockLmCoords.y);
	sunraysAmount *= 0.01;
	//sunraysAmount *= sunraysAmount * 0.001;
	
	return sunraysAmount;
}
