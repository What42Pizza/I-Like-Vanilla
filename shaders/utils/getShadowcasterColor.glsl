#undef INCLUDE_GET_SHADOWCASTER_COLOR

#if defined FIRST_PASS && !defined GET_SHADOWCASTER_COLOR_FIRST_FINISHED
	#define INCLUDE_GET_SHADOWCASTER_COLOR
	#define GET_SHADOWCASTER_COLOR_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_SHADOWCASTER_COLOR_SECOND_FINISHED
	#define INCLUDE_GET_SHADOWCASTER_COLOR
	#define GET_SHADOWCASTER_COLOR_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_SHADOWCASTER_COLOR



vec3 getShadowcasterColor(ARG_OUT) {
	
	#include "/import/sunNoonColorPercent.glsl"
	#include "/import/sunriseColorPercent.glsl"
	#include "/import/sunsetColorPercent.glsl"
	#include "/import/sunAngle.glsl"
	#include "/import/rainStrength.glsl"
	
	if (sunAngle < 0.5) {
		vec3 sunNoonLight = SKYLIGHT_DAY_COLOR * sunNoonColorPercent;
		vec3 sunSunriseLight = SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent;
		vec3 sunSunsetLight = SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
		vec3 sunLight = (sunNoonLight + sunSunriseLight + sunSunsetLight);
		sunLight *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
		return sunLight;
	} else {
		vec3 moonLight = SKYLIGHT_NIGHT_COLOR;
		moonLight *= 1.0 - rainStrength * (1.0 - RAIN_LIGHT_MULT);
		return moonLight;
	}
	
}



#endif
