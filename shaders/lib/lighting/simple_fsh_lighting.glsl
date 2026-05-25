void doSimpleFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specularness, vec3 viewPos, vec3 normal) {
	
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
	
	//vec2 prepareData10 = texelFetch(MISC_DATA_TEXTURE, ivec2(1, 0), 0).rg;
	vec2 prepareData01 = texelFetch(MISC_DATA_TEXTURE, ivec2(0, 1), 0).rg;
	vec2 prepareData11 = texelFetch(MISC_DATA_TEXTURE, ivec2(1, 1), 0).rg;
	//vec3 shadowcasterLight = vec3(prepareData10, prepareData01.r) * 2.0;
	vec3 ambientLight = vec3(prepareData01.g, prepareData11) * 2.0;
	ambientLight = mix(CAVE_AMBIENT_COLOR * 0.6 * (1.0 + 0.4 * screenBrightness), ambientLight, ambientBrightness);
	
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
	
	blockBrightness = percentThrough(blockBrightness, 0.0, 0.85);
	vec3 blockLight = mix(BLOCK_COLOR_DARK, BLOCK_COLOR_BRIGHT, blockBrightness * blockBrightness);
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	#ifdef OVERWORLD
		blockBrightness *= 1.0 + ambientBrightness * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	blockBrightness *= 1.0 - getLum(lighting) * 0.75;
	lighting = mix(lighting, blockLight, blockBrightness);
	
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 nightVisionMin = vec3(betterNightVision);
	nightVisionMin.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT * (1.0 - ambientBrightness);
	lighting += nightVisionMin * (1.0 - 0.75 * getLum(lighting));
	
	#if DO_COLOR_CODED_GBUFFERS == 1
		lighting = vec3(1.0);
	#endif
	color *= lighting;
	
}
