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



vec3 getSunlightColor(ARG_OUT) {
	#include "/import/sunNoonColorPercent.glsl"
	vec3 sunNoonLight = SKYLIGHT_DAY_COLOR * sunNoonColorPercent;
	#include "/import/sunriseColorPercent.glsl"
	vec3 sunSunriseLight = SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent;
	#include "/import/sunsetColorPercent.glsl"
	vec3 sunSunsetLight = SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
	vec3 sunlightColor = sunNoonLight + sunSunriseLight + sunSunsetLight;
	return sunlightColor;
}

vec3 getMoonlightColor(ARG_OUT) {
	return SKYLIGHT_NIGHT_COLOR;
}

vec3 getShadowcasterColor(ARG_OUT) {
	#include "/import/sunAngle.glsl"
	if (sunAngle < 0.5) {
		return getSunlightColor(ARG_IN);
	} else {
		return getMoonlightColor(ARG_IN);
	}
}



#endif
