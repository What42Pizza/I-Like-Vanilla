vec3 getDistortedShadowPos(vec3 shadowPos) {
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



float getVolSunraysAmount(vec3 playerPos, float distMult) {
	
	float blockDepth = length(playerPos);
	vec3 playerPosStep = playerPos / SUNRAYS_QUALITY;
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, vec3(0.0)));
	vec3 nextShadowPos = transform(shadowProjection, transform(shadowModelView, playerPosStep));
	vec3 shadowPosStep = nextShadowPos - shadowPos;
	
	// good values: 21.0015, 22.001, 0.02
	#ifdef GRADIENT_NOISE_SPEED
		#undef GRADIENT_NOISE_SPEED
	#endif
	#define GRADIENT_NOISE_SPEED 21.0015
	#include "/utils/var_gradient_noise.glsl"
	
	shadowPos += shadowPosStep * noise;
	
	float total = 0.0;
	for (int i = 0; i < SUNRAYS_QUALITY; i++) {
		vec3 distortedShadowPos = getDistortedShadowPos(shadowPos);
		float diff = texelFetch(shadowtex0, ivec2(distortedShadowPos.xy * shadowMapResolution), 0).r - distortedShadowPos.z;
		total += step(0.0, diff);
		shadowPos += shadowPosStep;
	}
	float sunraysAmount = total / SUNRAYS_QUALITY;
	sunraysAmount *= blockDepth;
	
	sunraysAmount += 8.0 * step(0.00001, sunraysAmount);
	
	return sunraysAmount;
}
