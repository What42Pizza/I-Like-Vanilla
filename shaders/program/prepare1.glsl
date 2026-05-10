flat in_out vec3 shadowCasterLight;
flat in_out vec3 ambientLight;



#ifdef FSH

void main() {
	/* RENDERTARGETS: 10 */
	if (texelcoord == ivec2(0, 0)) gl_FragData[0] = vec4(0.0, 0.0, 0.0, 1.0);
	if (texelcoord == ivec2(1, 0)) gl_FragData[0] = vec4(shadowCasterLight.rg * 0.5, 0.0, 1.0);
	if (texelcoord == ivec2(0, 1)) gl_FragData[0] = vec4(shadowCasterLight.b * 0.5, ambientLight.r * 0.5, 0.0, 1.0);
	if (texelcoord == ivec2(1, 1)) gl_FragData[0] = vec4(ambientLight.gb * 0.5, 0.0, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	
	
	
	// shadowCasterLight
	#ifdef OVERWORLD
		
		if (sunAngle < 0.5) {
			shadowCasterLight = SKYLIGHT_DAY_COLOR * sunNoonColorPercent
				+ SKYLIGHT_SUNRISE_COLOR * sunriseColorPercent
				+ SKYLIGHT_SUNSET_COLOR * sunsetColorPercent;
		} else {
			shadowCasterLight = SKYLIGHT_NIGHT_COLOR;
			const float[] phaseMults = float[8] (MOON_PHASE_BRIGHTNESS_MULT_1, MOON_PHASE_BRIGHTNESS_MULT_2, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_5, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_2);
			shadowCasterLight *= phaseMults[moonPhase];
		}
		
		shadowCasterLight *= 1.0 - 0.3 * inPaleGarden;
		shadowCasterLight *= 1.0 - 0.2 * (SHADOWS_BRIGHTNESS - 1.0);
		
	#elif defined NETHER
		shadowCasterLight = vec3(1.0);
	#elif defined END
		shadowCasterLight = END_SKYLIGHT_COLOR;
	#endif
	
	
	
	// ambientLight
	#ifdef OVERWORLD
		
		ambientLight =
			AMBIENT_DAY_COLOR * ambientSunPercent
			+ AMBIENT_NIGHT_COLOR * ambientMoonPercent
			+ AMBIENT_SUNRISE_COLOR * ambientSunrisePercent
			+ AMBIENT_SUNSET_COLOR * ambientSunsetPercent;
		
		const float[] phaseMults = float[8] (MOON_PHASE_BRIGHTNESS_MULT_1, MOON_PHASE_BRIGHTNESS_MULT_2, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_5, MOON_PHASE_BRIGHTNESS_MULT_4, MOON_PHASE_BRIGHTNESS_MULT_3, MOON_PHASE_BRIGHTNESS_MULT_2);
		ambientLight *= 1.0 - (1.0 - phaseMults[moonPhase]) * ambientMoonPercent;
		
		ambientLight *= SHADOWS_BRIGHTNESS;
		ambientLight *= 1.0 - 0.1 * inPaleGarden;
		
	#elif defined NETHER
		ambientLight = NETHER_AMBIENT_COLOR;
	#elif defined END
		ambientLight = END_AMBIENT_COLOR;
	#endif
	
	ambientLight *= 0.9 + 0.2 * screenBrightness;
	
	#if BSL_MODE == 1
		ambientLight *= 0.5;
	#endif
	
	
	
}

#endif
