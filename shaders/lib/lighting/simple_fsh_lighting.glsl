#include "/utils/getAmbientLight.glsl"



void doSimpleFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specularness, vec3 viewPos, vec3 normal) {
	
	#if defined OVERWORLD || defined END
		float lightDot = dot(normalize(shadowLightPosition), normal);
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
	
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	
	ambientLight *= 1.0 - rainStrength * (1.0 - mix(WEATHER_BRIGHTNESS_MULT_NIGHT, WEATHER_BRIGHTNESS_MULT_DAY, dayPercent)) * 0.25;
	vec3 lighting = ambientLight;
	
	#ifdef OVERWORLD
		lighting += lightningFlashAmount * LIGHTNING_BRIGHTNESS * 0.25 * ambientBrightness * ambientBrightness;
	#endif
	
	vec3 blockLight = mix(BLOCK_COLOR_DARK, BLOCK_COLOR_BRIGHT, blockBrightness * blockBrightness);
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
	lighting += nightVisionMin * (1.0 - 0.25 * getLum(lighting));
	
	#if DO_COLOR_CODED_GBUFFERS == 1
		lighting = vec3(1.0);
	#endif
	color *= lighting;
	
}
