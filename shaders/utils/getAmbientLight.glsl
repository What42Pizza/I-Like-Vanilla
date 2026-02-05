#ifndef INCLUDE_GET_AMBIENT_LIGHT
#define INCLUDE_GET_AMBIENT_LIGHT



vec3 getAmbientLight(float ambientBrightness, float lightDot) {
	
	#ifdef OVERWORLD
		
		vec3 ambientLight =
			AMBIENT_DAY_COLOR * ambientSunPercent
			+ AMBIENT_NIGHT_COLOR * ambientMoonPercent
			+ AMBIENT_SUNRISE_COLOR * ambientSunrisePercent
			+ AMBIENT_SUNSET_COLOR * ambientSunsetPercent;
		
		ambientLight *= SHADOWS_BRIGHTNESS;
		ambientLight *= 1.0 - 0.1 * inPaleGarden;
		ambientLight *= 1.0 + 0.0625 * clamp(1.0 - lightDot * 10.0, 0.0, 1.0);
		ambientBrightness *= 0.9 + 0.2 * screenBrightness;
		ambientLight = mix(CAVE_AMBIENT_COLOR * 0.6 * (1.0 + 0.4 * screenBrightness), ambientLight, ambientBrightness);
		
	#elif defined NETHER
		vec3 ambientLight = NETHER_AMBIENT_COLOR;
	#elif defined END
		vec3 ambientLight = END_AMBIENT_COLOR;
		ambientLight *= 0.8 + 0.4 * screenBrightness;
	#endif
	
	#if BSL_MODE == 1
		ambientLight *= 0.75;
	#endif
	
	return ambientLight;
}



#endif
