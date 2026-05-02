#include "/utils/getAmbientLight.glsl"



vec3 getPixelatedShadowPos(vec3 viewPos, vec3 normal) {
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	playerPos += cameraPosition;
	playerPos = floor(playerPos * PIXELATED_SHADOWS) / PIXELATED_SHADOWS;
	playerPos -= cameraPosition;
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}

vec3 getShadowPos(vec3 viewPos, vec3 normal) {
	viewPos += normal * 0.001 * (25.0 + length(viewPos));
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	vec3 shadowPos = transform(shadowProjection, transform(shadowModelView, playerPos));
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor);
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



#ifdef SHADOWS_ENABLED

#if PIXELATED_SHADOWS == 0 && SHADOW_FILTERING == 0
	#define samplePosType ivec2
	#define rawSample(sampler, pos) texelFetch(sampler, pos, 0)
#else
	#define samplePosType vec2
	#define rawSample(sampler, pos) texture2D(sampler, pos)
#endif

vec3 sampleShadowAtPoint(samplePosType shadowmapPos, float depth) {
	#if COLORED_SHADOWS_ENABLED == 0
		
		bool isLit = rawSample(shadowtex0, shadowmapPos).r >= depth;
		return vec3(float(isLit));
		
	#elif COLORED_SHADOWS_ENABLED == 1
		
		if (rawSample(shadowtex0, shadowmapPos).r >= depth) return vec3(1.0);
		if (rawSample(shadowtex1, shadowmapPos).r < depth) return vec3(0.0);
		vec4 shadowColor = rawSample(shadowcolor0, shadowmapPos);
		return shadowColor.rgb * (1.0 - shadowColor.a);
		
	#endif
}



vec3 sampleShadow(vec3 viewPos, float lightDot, vec3 normal) {
	if (lightDot < 0.0) return vec3(0.0); // surface is facing away from shadowLightPosition
	
	#if PIXELATED_SHADOWS > 0
		// no filtering, world-aligned pixelated
		
		viewPos += normal * 0.0025 * (40.0 + length(viewPos));
		
		vec3 tangent = cross(normal, gbufferModelView[1].xyz);
		if (abs(tangent.x) + abs(tangent.y) + abs(tangent.z) < 0.01) {
			tangent = cross(normal, gbufferModelView[0].xyz);
		}
		tangent = normalize(tangent);
		vec3 bitangent = cross(tangent, normal);
		
		vec3 shadowPos = getPixelatedShadowPos(viewPos, normal);
		if (shadowPos.z > 1.0) return vec3(1.0);
		vec3 shadowPosStepX = normalize(mat3(shadowProjection) * mat3(shadowModelView) * mat3(gbufferModelViewInverse) * tangent);
		vec3 shadowPosStepY = normalize(mat3(shadowProjection) * mat3(shadowModelView) * mat3(gbufferModelViewInverse) * bitangent);
		shadowPosStepX *= PIXELATED_SHADOWS_SOFTNESS * 0.0008;
		shadowPosStepY *= PIXELATED_SHADOWS_SOFTNESS * 0.0008;
		
		vec3 shadowSample = vec3(0.0);
		float bias = 0.0002 + length(viewPos) * 0.035 / shadowMapResolution;
		shadowSample += sampleShadowAtPoint(shadowPos.xy + shadowPosStepX.xy + shadowPosStepY.xy, shadowPos.z - bias);
		shadowSample += sampleShadowAtPoint(shadowPos.xy + shadowPosStepX.xy - shadowPosStepY.xy, shadowPos.z - bias);
		shadowSample += sampleShadowAtPoint(shadowPos.xy - shadowPosStepX.xy + shadowPosStepY.xy, shadowPos.z - bias);
		shadowSample += sampleShadowAtPoint(shadowPos.xy - shadowPosStepX.xy - shadowPosStepY.xy, shadowPos.z - bias);
		return shadowSample * 0.25;
		
	#elif SHADOW_FILTERING == 0
		
		// no filtering, pixelated edges
		vec3 shadowPos = getShadowPos(viewPos, normal);
		if (shadowPos.z > 1.0) return vec3(1.0);
		return sampleShadowAtPoint(ivec2(shadowPos.xy * shadowMapResolution - 0.25), shadowPos.z);
		
	#elif SHADOW_FILTERING == 1
		
		// no filtering, smooth edges
		vec3 shadowPos = getShadowPos(viewPos, normal);
		if (shadowPos.z > 1.0) return vec3(1.0);
		return sampleShadowAtPoint(shadowPos.xy, shadowPos.z);
		
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
		
		vec3 shadowPos = getShadowPos(viewPos, normal);
		if (shadowPos.z > 1.0) return vec3(1.0);
		
		float dither = bayer64(gl_FragCoord.xy);
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		float randomAngle = dither * 2.0 * PI;
		float noiseMult = SHADOWS_NOISE / shadowMapResolution * 3.0 * (1.0 + 2.0 * length(shadowPos.xy - 0.5));
		mat2 rotationMatrix;
		rotationMatrix[1] = vec2(sin(randomAngle), cos(randomAngle)) * noiseMult;
		rotationMatrix[0] = vec2(-rotationMatrix[1].y, rotationMatrix[1].x);
		
		vec3 shadowSample = vec3(0.0);
		for (int i = 0; i < SHADOW_OFFSET_COUNT; i++) {
			vec2 samplePos = shadowPos.xy + rotationMatrix * SHADOW_OFFSETS[i].xy;
			shadowSample += sampleShadowAtPoint(samplePos, shadowPos.z) * SHADOW_OFFSETS[i].z;
		}
		shadowSample /= SHADOW_OFFSET_WEIGHTS_TOTAL;
		float mult = min(getLum(shadowSample) * 2.5, 1.0);
		shadowSample = shadowSample / getLum(shadowSample + 0.1) * mult * mult;
		return shadowSample;
		
	#endif
}

#endif





void doFshLighting(inout vec3 color, out float inSunlightAmount, float blockBrightness, float ambientBrightness, float specularness, float glowingAmount, vec3 viewPos, vec3 normal, float depth) {
	
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
	
	#if defined OVERWORLD || defined END
		float lightDot = dot(normalize(shadowLightPosition), normal);
		#ifdef SHADOWS_ENABLED
			float lightDotLift = 0.3;
		#else
			float lightDotLift = 1.0;
		#endif
		// TODO: reintroduce 'SUNLIGHT_CEL_AMOUNT' here?
		lightDot = lightDotLift * 0.5 + (1.0 - lightDotLift * 0.5) * lightDot;
	#else
		float lightDot = 1.0;
	#endif
	
	// night saturation decrease
	#ifdef OVERWORLD
		float nightPercent = 1.0 - dayPercent;
		nightPercent *= ambientBrightness * (1.0 - blockBrightness);
		nightPercent *= nightPercent;
		nightPercent *= NIGHT_SATURATION_DECREASE;
		color = mix(vec3(getLum(color)), color, 1.0 - nightPercent * 0.1);
		color += nightPercent * 0.06;
	#endif
	
	#ifdef END
		ambientBrightness = 1.0;
	#endif
	
	vec3 ambientLight = getAmbientLight(ambientBrightness, lightDot);
	
	vec3 normalForSS = mat3(gbufferModelViewInverse) * normal;
	// +-1.0x: -0.4
	// +-1.0z: -0.0
	// +1.0y: +0.325
	// -1.0y: -0.65
	normalForSS.xz = abs(normalForSS.xz);
	normalForSS.y *= sign(normalForSS.y) * -0.25 + 0.75; // -1: *1, 1: *0.5
	float sideShading = dot(normalForSS, vec3(-0.4, 0.65, 0.0));
	float brightForSS = max(blockBrightness, ambientBrightness);
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, brightForSS * brightForSS) * 0.8;
	
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	
	#ifdef SHADOWS_ENABLED
		vec3 shadowColor = sampleShadow(viewPos, lightDot, normal);
		inSunlightAmount = getLum(shadowColor);
		#if PIXELATED_SHADOWS > 0
			inSunlightAmount *= float(depthIsHand(depth));
		#endif
	#else
		vec3 shadowColor = vec3(1.0);
		inSunlightAmount = 1.0;
	#endif
	inSunlightAmount *= min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	inSunlightAmount *= clamp(lightDot, 0.0, 1.0);
	inSunlightAmount *= ambientBrightness * ambientBrightness;
	inSunlightAmount *= 1.0 - rainStrength * (1.0 - mix(WEATHER_BRIGHTNESS_MULT_NIGHT, WEATHER_BRIGHTNESS_MULT_DAY, dayPercent));
	
	shadowColor = shadowColor / (getLum(shadowColor) + 0.00001) * inSunlightAmount * shadowcasterLight;
	ambientLight *= 1.0 - inSunlightAmount;
	
	ambientLight *= 1.0 - rainStrength * (1.0 - mix(WEATHER_BRIGHTNESS_MULT_NIGHT, WEATHER_BRIGHTNESS_MULT_DAY, dayPercent)) * 0.25;
	vec3 lighting = ambientLight + shadowColor;
	
	#ifdef OVERWORLD
		lighting += lightningFlashAmount * LIGHTNING_BRIGHTNESS * 0.25 * ambientBrightness * ambientBrightness;
	#endif
	
	#ifdef OVERWORLD
		vec3 reflectedDir = normalize(reflect(viewPos, normal));
		vec3 lightDir = normalize(shadowLightPosition);
		float specular = max(dot(reflectedDir, lightDir), 0.0);
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular *= 1.0 - betterRainStrength;
		vec3 specularColor = shadowColor * (sunAngle < 0.5 ? vec3(1.0, 1.0, 0.6) : vec3(0.5, 0.7, 0.9) * 0.75);
		#if PBR_TYPE == 0
			specular *= 1.0 - 0.25 * getSaturation(color);
		#endif
		lighting += specularColor * specular * (0.1 + 0.5 * specularness) * min(inSunlightAmount * 64.0, 1.0) * min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	#endif
	
	vec3 blockLight = mix(BLOCK_COLOR_DARK, BLOCK_COLOR_BRIGHT, blockBrightness * blockBrightness);
	#ifdef OVERWORLD
		blockBrightness *= 1.0 + ambientBrightness * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	blockBrightness *= 1.0 - min(getLum(lighting), 1.0);
	lighting *= 1.0 - blockBrightness;
	blockLight *= blockBrightness;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	lighting += blockLight;
	
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 nightVisionMin = vec3(betterNightVision);
	nightVisionMin.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT;
	nightVisionMin *= 1.0 + 0.5 * sideShading;
	lighting += nightVisionMin * (1.0 - 0.25 * getLum(lighting));
	
	lighting += glowingAmount * vec3(1.0, 0.85, 0.8);
	
	lighting *= 1.0 + sideShading;
	
	#if DO_COLOR_CODED_GBUFFERS == 1
		lighting = vec3(1.0);
	#endif
	color *= lighting;
	
}
