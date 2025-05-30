#undef INCLUDE_GET_AMBIENT_LIGHT

#if defined FIRST_PASS && !defined GET_AMBIENT_LIGHT_FIRST_FINISHED
	#define INCLUDE_GET_AMBIENT_LIGHT
	#define GET_AMBIENT_LIGHT_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_AMBIENT_LIGHT_SECOND_FINISHED
	#define INCLUDE_GET_AMBIENT_LIGHT
	#define GET_AMBIENT_LIGHT_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_AMBIENT_LIGHT



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
		ambientLight = mix(CAVE_AMBIENT_COLOR * (0.6 + 0.8 * screenBrightness) * 0.5, ambientLight, ambientBrightness);
		
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



#endif
