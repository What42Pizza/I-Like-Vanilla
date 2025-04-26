#ifdef FSH



#include "/utils/getAmbientLight.glsl"



vec3 getShadowPos(vec3 viewPos, float lightDot, vec3 normal  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	#if PIXELATED_SHADOWS > 0
		#include "/import/cameraPosition.glsl"
		playerPos += cameraPosition;
		playerPos = floor(playerPos * PIXELATED_SHADOWS + normal * 0.15) / PIXELATED_SHADOWS;
		playerPos -= cameraPosition;
	#endif
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	float bias =
		0.05
		+ 0.01 / (lightDot + 0.03)
		+ distortFactor * distortFactor * 0.5;
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= bias * 0.02;
	return shadowPos;
}

vec3 getLessBiasedShadowPos(vec3 viewPos  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= 0.005 * distortFactor;
	return shadowPos;
}



float sampleShadow(vec3 viewPos, float lightDot, vec3 normal  ARGS_OUT) {
	if (lightDot < 0.0) return 0.0; // surface is facing away from shadowLightPosition
	
	#if PIXELATED_SHADOWS > 0
		
		// no filtering, pixelated edges
		vec3 shadowPos = getShadowPos(viewPos, lightDot, normal  ARGS_IN);
		return (texelFetch(shadowtex0, ivec2(shadowPos.xy * shadowMapResolution), 0).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#elif SHADOW_FILTERING == 0
		
		// no filtering, pixelated edges
		vec3 shadowPos = getShadowPos(viewPos, lightDot, normal  ARGS_IN);
		return (texelFetch(shadowtex0, ivec2(shadowPos.xy * shadowMapResolution), 0).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#elif SHADOW_FILTERING == 1
		
		// no filtering, smooth edges
		vec3 shadowPos = getShadowPos(viewPos, lightDot, normal  ARGS_IN);
		return (texture2D(shadowtex0, shadowPos.xy).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#else
		
		
		
		// strange filtering
		
		#if SHADOW_FILTERING == 2
			const int SHADOW_OFFSET_COUNT = 5;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 3.584;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3(-0.200,  0.013, 0.967),
				vec3(-0.124, -0.380, 0.873),
				vec3(-0.383,  0.462, 0.736),
				vec3( 0.747, -0.285, 0.580),
				vec3( 0.613,  0.790, 0.427)
			);
		#elif SHADOW_FILTERING == 3
			const int SHADOW_OFFSET_COUNT = 10;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 7.472;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3(-0.069,  0.072, 0.992),
				vec3( 0.161, -0.119, 0.967),
				vec3( 0.212,  0.212, 0.926),
				vec3(-0.261, -0.303, 0.873),
				vec3(-0.497, -0.058, 0.809),
				vec3( 0.027, -0.599, 0.736),
				vec3(-0.460,  0.528, 0.659),
				vec3( 0.702, -0.384, 0.580),
				vec3( 0.215,  0.874, 0.502),
				vec3( 0.917,  0.400, 0.427)
			);
		#elif SHADOW_FILTERING == 4
			const int SHADOW_OFFSET_COUNT = 20;
			const float SHADOW_OFFSET_WEIGHTS_TOTAL = 15.239;
			const vec3[SHADOW_OFFSET_COUNT] SHADOW_OFFSETS = vec3[SHADOW_OFFSET_COUNT] (
				vec3(-0.029,  0.040, 0.998),
				vec3( 0.094, -0.034, 0.992),
				vec3(-0.100, -0.112, 0.981),
				vec3( 0.101,  0.173, 0.967),
				vec3(-0.248,  0.033, 0.948),
				vec3( 0.028, -0.299, 0.926),
				vec3(-0.189,  0.295, 0.901),
				vec3( 0.353, -0.188, 0.873),
				vec3( 0.417,  0.170, 0.842),
				vec3( 0.159,  0.474, 0.809),
				vec3(-0.439, -0.331, 0.773),
				vec3(-0.593, -0.091, 0.736),
				vec3(-0.264, -0.594, 0.698),
				vec3( 0.169, -0.679, 0.659),
				vec3(-0.672,  0.333, 0.620),
				vec3(-0.315,  0.736, 0.580),
				vec3( 0.668, -0.526, 0.541),
				vec3( 0.900,  0.010, 0.502),
				vec3( 0.729,  0.609, 0.464),
				vec3( 0.233,  0.972, 0.427)
			);
		#endif
		
		vec3 shadowPos = getLessBiasedShadowPos(viewPos  ARGS_IN);
		
		float dither = bayer64(gl_FragCoord.xy);
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		float randomAngle = (dither - 0.5) * 2.0 * PI;
		mat2 rotationMatrix;
		#include "/import/invAspectRatio.glsl"
		rotationMatrix[0] = vec2(cos(randomAngle), -sin(randomAngle)) * 0.005 * SHADOWS_NOISE;
		rotationMatrix[1] = vec2(sin(randomAngle), cos(randomAngle)) * 0.005 * SHADOWS_NOISE;
		
		float shadowBrightness = 0.0;
		for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
			if (texture2D(shadowtex0, shadowPos.xy + rotationMatrix * SHADOW_OFFSETS[i].xy).r >= shadowPos.z) {
				float currentShadowWeight = SHADOW_OFFSETS[i].z;
				shadowBrightness += currentShadowWeight;
			}
		}
		shadowBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
		#if TEMPORAL_FILTER_ENABLED == 1
			const float shadowMult1 = 1.4; // for when lightDot is 1.0 (sun is directly facing surface)
			const float shadowMult2 = 2.2; // for when lightDot is 0.0 (sun is angled relative to surface)
		#else
			const float shadowMult1 = 2.0; // for when lightDot is 1.0 (sun is directly facing surface)
			const float shadowMult2 = 3.0; // for when lightDot is 0.0 (sun is angled relative to surface)
		#endif
		float shadowSample = min(shadowBrightness * mix(shadowMult1, shadowMult2, lightDot), 1.0);
		return shadowSample * shadowSample;
		
	#endif
}



float getSkyBrightness(vec3 viewPos, vec3 normal, float ambientBrightness  ARGS_OUT) {
	
	// get normal dot sun/moon pos
	#ifdef OVERWORLD
		#include "/import/shadowLightPosition.glsl"
		float lightDot = dot(normalize(shadowLightPosition), normal);
	#else
		float lightDot = 1.0;
	#endif
	
	// sample shadow
	#if SHADOWS_ENABLED == 1
		float skyBrightness = sampleShadow(viewPos, lightDot, normal  ARGS_IN);
		#ifdef DISTANT_HORIZONS
			#include "/import/invFar.glsl"
			float len = max(length(viewPos) * invFar, 0.8);
			skyBrightness = mix(skyBrightness, ambientBrightness, smoothstep(len, 0.75, 0.8));
		#endif
	#else
		float skyBrightness = ambientBrightness;
	#endif
	
	skyBrightness *= max(lightDot, 0.0);
	
	return skyBrightness;
}



void doFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#if CEL_SHADING_ENABLED == 1
		blockBrightness =
			0.8 * sqrt(blockBrightness) +
			0.2 * step(0.2, blockBrightness);
		ambientBrightness = smoothstep(0.0, 1.0, ambientBrightness);
	#endif
	
	vec3 ambientLight = getAmbientLight(ambientBrightness  ARGS_IN);
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT;
	#endif
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	#include "/import/moonLightBrightness.glsl"
	#ifdef OVERWORLD
		#include "/import/eyeBrightness.glsl"
		blockBrightness *= 1.0 + (eyeBrightness.y / 240.0) * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	
	#include "/import/sunLightBrightness.glsl"
	float skyBrightness = getSkyBrightness(viewPos, normal, ambientBrightness  ARGS_IN) * min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	skyBrightness *= ambientBrightness;
	
	#include "/import/rainStrength.glsl"
	#include "/import/dayPercent.glsl"
	float rainDecrease = rainStrength * dayPercent * (1.0 - WEATHER_LIGHT_MULT);
	skyBrightness *= 1.0 - rainDecrease;
	vec3 skyLighting = shadowcasterColor * skyBrightness;
	ambientLight *= 1.0 - skyBrightness;
	
	vec3 lighting = ambientLight + skyLighting;
	lighting *= 1.0 - rainDecrease;
	
	float lightingBrightness = min(getColorLum(lighting), 1.0);
	blockBrightness *= 1.1 - lightingBrightness;
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	lighting += blockLight;
	
	color *= lighting * 1.2;
	
}



#endif
