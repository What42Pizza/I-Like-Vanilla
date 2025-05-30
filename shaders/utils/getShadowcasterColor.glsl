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
	#ifdef OVERWORLD
		#include "/import/sunAngle.glsl"
		if (sunAngle < 0.5) {
			#include "/import/sunNoonColorPercent.glsl"
			#include "/import/sunriseColorPercent.glsl"
			#include "/import/sunsetColorPercent.glsl"
			return SKYLIGHT_DAY_COLOR * sunNoonColorPercent
				+ SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent
				+ SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
		} else {
			return SKYLIGHT_NIGHT_COLOR;
		}
	#elif defined NETHER
		return vec3(0.0);
	#elif defined END
		return END_SKYLIGHT_COLOR;
	#endif
}



#endif
