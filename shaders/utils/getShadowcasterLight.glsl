#undef INCLUDE_GET_SHADOWCASTER_LIGHT

#if defined FIRST_PASS && !defined GET_SHADOWCASTER_LIGHT_FIRST_FINISHED
	#define INCLUDE_GET_SHADOWCASTER_LIGHT
	#define GET_SHADOWCASTER_LIGHT_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_SHADOWCASTER_LIGHT_SECOND_FINISHED
	#define INCLUDE_GET_SHADOWCASTER_LIGHT
	#define GET_SHADOWCASTER_LIGHT_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_SHADOWCASTER_LIGHT



vec3 getShadowcasterLight(ARG_OUT) {
	#ifdef OVERWORLD
		vec3 shadowcasterLight;
		
		#include "/import/sunAngle.glsl"
		if (sunAngle < 0.5) {
			#include "/import/sunNoonColorPercent.glsl"
			#include "/import/sunriseColorPercent.glsl"
			#include "/import/sunsetColorPercent.glsl"
			shadowcasterLight = SKYLIGHT_DAY_COLOR * sunNoonColorPercent
				+ SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent
				+ SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
		} else {
			shadowcasterLight = SKYLIGHT_NIGHT_COLOR;
		}
		
		#include "/import/inPaleGarden.glsl"
		shadowcasterLight *= 1.0 - 0.3 * inPaleGarden;
		shadowcasterLight *= 1.0 - 0.2 * (SHADOWS_BRIGHTNESS - 1.0);
		
		return shadowcasterLight;
	#elif defined NETHER
		return vec3(0.0);
	#elif defined END
		return END_SKYLIGHT_COLOR;
	#endif
}



#endif
