#ifndef INCLUDE_GET_SKY_COLOR
#define INCLUDE_GET_SKY_COLOR



vec3 getFogColor(vec3 viewPos, vec3 playerPos, float skylightBrightness) {
	vec3 fogColorOut;
	
	#ifdef OVERWORLD
		
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.75 + 0.1;
			const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.75 + 0.1;
			const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR;
			const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR;
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.8 + 0.05;
			const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.3;
			const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.8 + 0.1;
			const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR * 0.75;
			const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR * 0.75;
		#endif
		
		float sunriseSunsetPercent = ambientSunrisePercent + ambientSunsetPercent;
		vec3 viewDir = normalize(viewPos);
		
		float skyMixFactor = dayPercent;
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		fogColorOut = mix(NIGHT_COLOR, DAY_COLOR, skyMixFactor);
		fogColorOut = mix(fogColorOut, vec3(0.05 + dayPercent * 0.4), inPaleGarden);
		upDot = max(upDot, 0.0);
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, skyMixFactor);
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			horizonColor *= 1.0 - 0.4 * sunriseSunsetPercent;
			fogColorOut *= 1.0 - 0.4 * sunriseSunsetPercent;
		#endif
		horizonColor = mix(horizonColor, vec3(0.1 + 0.25 * dayPercent), inPaleGarden);
		float horizonAmount = 1.0 - upDot;
		horizonAmount *= horizonAmount;
		horizonAmount *= horizonAmount;
		horizonAmount = 1.0 - horizonAmount;
		fogColorOut = mix(horizonColor, fogColorOut, horizonAmount);
		
		float sunDot = dot(viewDir, sunPosition * 0.01) * 0.5 + 0.5;
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			sunDot *= sunDot;
		#endif
		sunDot *= 1.0 - upDot;
		sunDot *= 1.0 - (1.0 - sunriseSunsetPercent) * (1.0 - sunriseSunsetPercent);
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		fogColorOut = mix(fogColorOut, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		float rainAmount = rainStrength * SKY_WEATHER_DESATURATION;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		fogColorOut = mix(fogColorOut, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		fogColorOut *= 2.0/3.0;
		fogColorOut = min(fogColorOut, 1.0);
		fogColorOut = 1.0 - (fogColorOut - 1.0) * (fogColorOut - 1.0);
		fogColorOut *= 3.0/2.0 * 1.2;
		fogColorOut *= 0.3 + 0.7 * dayPercent;
		
		float worldAltitude = playerPos.y / UNDERGROUND_FOG_ALTITUDE_IMPACT + eyeAltitude;
		float darkenAmount = percentThrough(worldAltitude, SEA_LEVEL, SEA_LEVEL - 24);
		darkenAmount = max(darkenAmount, 1.0 - skylightBrightness * skylightBrightness);
		darkenAmount *= uint(isEyeInWater == 0);
		fogColorOut = mix(fogColorOut, vec3(UNDERGROUND_FOG_BRIGHTNESS), darkenAmount);
		
	#elif defined NETHER
		
		// must stay the same as in /utils/getSkyColor.glsl
		fogColorOut = fogColor;
		fogColorOut = mix(vec3(getLum(fogColorOut)), fogColorOut, NETHER_SKY_FOG_SATURATION);
		fogColorOut = NETHER_SKY_BASE_COLOR + NETHER_SKY_FOG_INFLUENCE * fogColorOut;
		
	#elif defined END
		
		fogColorOut = vec3(0.4, 0.2, 0.5);
		
	#endif
	
	if (isEyeInWater == 1) {
		fogColorOut = WATER_FOG_COLOR * (0.25 + 0.75 * max(dayPercent, eyeBrightnessSmooth.x / 240.0));
	} else if (isEyeInWater == 2) {
		fogColorOut = LAVA_FOG_COLOR * (0.25 + 0.75 * max(dayPercent, eyeBrightnessSmooth.x / 240.0));
	} else if (isEyeInWater == 3) {
		fogColorOut = POWDERED_SNOW_FOG_COLOR * (0.25 + 0.75 * max(dayPercent, eyeBrightnessSmooth.x / 240.0));
	}
	
	return fogColorOut;
	
}



#endif
