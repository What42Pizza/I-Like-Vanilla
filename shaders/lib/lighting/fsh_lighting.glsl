vec3 getPixelatedShadowPos(vec3 viewPos, vec3 normal  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos + normal * 0.05);
	#include "/import/cameraPosition.glsl"
	playerPos += cameraPosition;
	playerPos = floor(playerPos * PIXELATED_SHADOWS) / PIXELATED_SHADOWS;
	playerPos -= cameraPosition;
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	shadowPos.z -= 0.00009 + length(viewPos) * 0.02 / shadowMapResolution;
	return shadowPos;
}

vec3 getShadowPos(vec3 viewPos, vec3 normal  ARGS_OUT) {
	viewPos += normal * 0.001 * (25.0 + length(viewPos));
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



float sampleShadow(vec3 viewPos, float lightDot, vec3 normal  ARGS_OUT) {
	if (lightDot < 0.0) return 0.0; // surface is facing away from shadowLightPosition
	
	#if PIXELATED_SHADOWS > 0
		
		// no filtering, pixelated edges
		vec3 shadowPos = getPixelatedShadowPos(viewPos, normal  ARGS_IN);
		return (texelFetch(shadowtex0, ivec2(shadowPos.xy * shadowMapResolution), 0).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#elif SHADOW_FILTERING == 0
		
		// no filtering, pixelated edges
		vec3 shadowPos = getShadowPos(viewPos, normal  ARGS_IN);
		return (texelFetch(shadowtex0, ivec2(shadowPos.xy * shadowMapResolution), 0).r >= shadowPos.z) ? 1.0 : 0.0;
		
	#elif SHADOW_FILTERING == 1
		
		// no filtering, smooth edges
		vec3 shadowPos = getShadowPos(viewPos, normal  ARGS_IN);
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
		
		vec3 shadowPos = getShadowPos(viewPos, normal  ARGS_IN);
		
		float dither = bayer64(gl_FragCoord.xy);
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		float randomAngle = dither * 2.0 * PI;
		mat2 rotationMatrix;
		rotationMatrix[0] = vec2(cos(randomAngle), -sin(randomAngle));
		rotationMatrix[1] = vec2(sin(randomAngle), cos(randomAngle));
		float noiseMult = SHADOWS_NOISE / shadowMapResolution * 3.0 * (1.0 + 2.0 * length(shadowPos.xy - 0.5));
		rotationMatrix[0] *= noiseMult;
		rotationMatrix[1] *= noiseMult;
		
		float shadowBrightness = 0.0;
		for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
			if (texture2D(shadowtex0, shadowPos.xy + rotationMatrix * SHADOW_OFFSETS[i].xy).r >= shadowPos.z) {
				float currentShadowWeight = SHADOW_OFFSETS[i].z;
				shadowBrightness += currentShadowWeight;
			}
		}
		shadowBrightness /= SHADOW_OFFSET_WEIGHTS_TOTAL;
		float shadowSample = min(shadowBrightness * 2.5, 1.0);
		return shadowSample * shadowSample;
		
	#endif
}



float getShadowBrightness(vec3 viewPos, vec3 normal, float ambientBrightness  ARGS_OUT) {
	
	// get normal dot sun/moon pos
	#ifdef OVERWORLD
		#include "/import/shadowLightPosition.glsl"
		float lightDot = dot(normalize(shadowLightPosition), normal);
	#else
		float lightDot = 1.0;
	#endif
	
	// sample shadow
	#if SHADOWS_ENABLED == 1
		float shadowBrightness = sampleShadow(viewPos, lightDot, normal  ARGS_IN);
		#ifdef DISTANT_HORIZONS
			#include "/import/invFar.glsl"
			float len = max(length(viewPos) * invFar, 0.8);
			shadowBrightness = mix(shadowBrightness, ambientBrightness, smoothstep(len, 0.75, 0.8));
		#endif
	#else
		float shadowBrightness = ambientBrightness;
	#endif
	
	const float SUNLIGHT_CEL_INTERMEDIATE = 1.0 - (1.0 - SUNLIGHT_CEL_AMOUNT) * (1.0 - SUNLIGHT_CEL_AMOUNT);
	const float SUNLIGHT_CEL_SHADING_MULT = 1.0 / (1.01 - SUNLIGHT_CEL_INTERMEDIATE);
	shadowBrightness *= clamp(lightDot * SUNLIGHT_CEL_SHADING_MULT, 0.0, 1.0);
	
	return shadowBrightness;
}



vec3 getAmbientLight(float ambientBrightness  ARGS_OUT) {
	
	#ifdef OVERWORLD
		
		#include "/import/ambientSunPercent.glsl"
		#include "/import/ambientMoonPercent.glsl"
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
		vec3 ambientLight =
			AMBIENT_DAY_COLOR * ambientSunPercent
			+ AMBIENT_NIGHT_COLOR * ambientMoonPercent
			+ AMBIENT_SUNRISE_COLOR * ambientSunrisePercent
			+ AMBIENT_SUNSET_COLOR * ambientSunsetPercent;
		
		#include "/import/screenBrightness.glsl"
		ambientBrightness *= 0.9 + 0.2 * screenBrightness;
		ambientLight = mix(CAVE_AMBIENT_COLOR * (0.6 + 0.8 * screenBrightness) * 0.6, ambientLight, ambientBrightness);
		
	#elif defined NETHER
		vec3 ambientLight = NETHER_AMBIENT_COLOR;
	#elif defined END
		vec3 ambientLight = END_AMBIENT_COLOR;
		#include "/import/screenBrightness.glsl"
		ambientLight *= 0.8 + 0.4 * screenBrightness;
	#endif
	
	#include "/import/nightVision.glsl"
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 lightVisionMin = vec3(betterNightVision);
	lightVisionMin.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT;
	ambientLight = max(ambientLight, lightVisionMin);
	
	return ambientLight;
}



void doFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specular_amount, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
	#if AMBIENT_CEL_AMOUNT != 0
		ambientBrightness = sqrt(ambientBrightness);
		ambientBrightness = mix(ambientBrightness, floor(ambientBrightness * 3.0 + 0.5) / 3.0, AMBIENT_CEL_AMOUNT / 100.0);
		ambientBrightness *= ambientBrightness;
	#endif
	#if BLOCKLIGHT_CEL_AMOUNT != 0
		blockBrightness = sqrt(blockBrightness);
		blockBrightness = mix(blockBrightness, floor(blockBrightness * 3.0 + 0.5) / 3.0, BLOCKLIGHT_CEL_AMOUNT / 100.0);
		blockBrightness *= blockBrightness;
	#endif
	
	#if HANDHELD_LIGHT_ENABLED == 1
		float viewPosLen = length(viewPos);
		if (viewPosLen <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - viewPosLen / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			blockBrightness = max(blockBrightness, handLightBrightness);
		}
	#endif
	
	// night saturation decrease
	#include "/import/dayPercent.glsl"
	float nightPercent = 1.0 - dayPercent;
	nightPercent *= ambientBrightness * (1.0 - blockBrightness);
	nightPercent *= nightPercent;
	nightPercent *= NIGHT_SATURATION_DECREASE;
	color = mix(vec3(getLum(color)), color, 1.0 - nightPercent * 0.1);
	color += nightPercent * 0.06;
	
	#ifdef END
		ambientBrightness = 1.0;
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
	float shadowBrightness = getShadowBrightness(viewPos, normal, ambientBrightness  ARGS_IN);
	shadowBrightness *= min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	shadowBrightness *= ambientBrightness;
	
	#include "/import/rainStrength.glsl"
	float rainDecrease = rainStrength * dayPercent * (1.0 - WEATHER_BRIGHTNESS_MULT);
	shadowBrightness *= 1.0 - rainDecrease;
	vec3 skyLighting = shadowcasterColor * shadowBrightness * (1.0 - 0.2 * (SHADOWS_BRIGHTNESS - 1.0));
	#include "/import/inPaleGarden.glsl"
	skyLighting *= 1.0 - 0.3 * inPaleGarden;
	ambientLight *= 1.0 - shadowBrightness;
	ambientLight *= SHADOWS_BRIGHTNESS;
	ambientLight *= 1.0 - 0.1 * inPaleGarden;
	
	vec3 lighting = ambientLight + skyLighting;
	lighting *= 1.0 - rainDecrease;
	
	#ifdef OVERWORLD
		vec3 reflectedDir = normalize(reflect(viewPos, normal));
		#include "/import/shadowLightPosition.glsl"
		vec3 lightDir = normalize(shadowLightPosition);
		float specular = max(dot(reflectedDir, lightDir), 0.0);
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular = 1.0 - (1.0 - specular) * (1.0 - specular);
		#include "/import/betterRainStrength.glsl"
		specular *= 1.0 - betterRainStrength;
		#include "/import/ambientMoonPercent.glsl"
		lighting += vec3(1.0, 1.0, 0.5) * specular * (0.2 + 0.75 * specular_amount) * shadowBrightness * (1.0 - 0.8 * ambientMoonPercent);
	#endif
	
	float lightingBrightness = min(getLum(lighting), 1.0);
	blockBrightness *= 1.2 - lightingBrightness;
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	lighting += blockLight;
	
	color *= lighting;
	
}
