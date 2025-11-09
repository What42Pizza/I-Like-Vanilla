#ifndef INCLUDE_GET_SHADOWCASTER_LIGHT
#define INCLUDE_GET_SHADOWCASTER_LIGHT



vec3 getShadowcasterLight() {
	#ifdef OVERWORLD
		vec3 shadowcasterLight;
		
		if (sunAngle < 0.5) {
			shadowcasterLight = SKYLIGHT_DAY_COLOR * sunNoonColorPercent
				+ SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent
				+ SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
		} else {
			shadowcasterLight = SKYLIGHT_NIGHT_COLOR;
		}
		
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
