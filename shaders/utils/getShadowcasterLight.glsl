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
			const float[] phaseMults = float[8] (MOON_PHASE_BRIGHTNESS_MULT_1, MOON_PHASE_BRIGHTNESS_MULT_2, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_5, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_2);
			shadowcasterLight *= phaseMults[moonPhase];
		}
		
		shadowcasterLight *= 1.0 - 0.3 * inPaleGarden;
		shadowcasterLight *= 1.0 - 0.2 * (SHADOWS_BRIGHTNESS - 1.0);
		
		return shadowcasterLight;
	#elif defined NETHER
		return vec3(1.0);
	#elif defined END
		return END_SKYLIGHT_COLOR;
	#endif
}



#endif
