#ifndef INCLUDE_GET_SKY_COLOR
#define INCLUDE_GET_SKY_COLOR



vec3 getFogColor(vec3 viewPos, vec3 playerPos, float skylightBrightness) {
	vec3 fogColor;
	
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
		fogColor = mix(NIGHT_COLOR, DAY_COLOR, skyMixFactor);
		fogColor = mix(fogColor, vec3(0.05 + dayPercent * 0.4), inPaleGarden);
		upDot = max(upDot, 0.0);
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, skyMixFactor);
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			horizonColor *= 1.0 - 0.4 * sunriseSunsetPercent;
			fogColor *= 1.0 - 0.4 * sunriseSunsetPercent;
		#endif
		horizonColor = mix(horizonColor, vec3(0.1 + 0.25 * dayPercent), inPaleGarden);
		float horizonAmount = 1.0 - upDot;
		horizonAmount *= horizonAmount;
		horizonAmount *= horizonAmount;
		horizonAmount = 1.0 - horizonAmount;
		fogColor = mix(horizonColor, fogColor, horizonAmount);
		
		float sunDot = dot(viewDir, sunPosition * 0.01) * 0.5 + 0.5;
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			sunDot *= sunDot;
		#endif
		sunDot *= 1.0 - upDot;
		sunDot *= 1.0 - (1.0 - sunriseSunsetPercent) * (1.0 - sunriseSunsetPercent);
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		fogColor = mix(fogColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		float rainAmount = rainStrength * 0.7;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		fogColor = mix(fogColor, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		fogColor *= 2.0/3.0;
		fogColor = min(fogColor, 1.0);
		fogColor = 1.0 - (fogColor - 1.0) * (fogColor - 1.0);
		fogColor *= 3.0/2.0 * 1.2;
		fogColor *= 0.3 + 0.7 * dayPercent;
		
		float worldAltitude = playerPos.y + eyeAltitude;
		float darkenAmount = percentThrough(worldAltitude, 64, 40);
		darkenAmount = max(darkenAmount, 1.0 - skylightBrightness * skylightBrightness);
		darkenAmount *= uint(isEyeInWater == 0);
		fogColor = mix(fogColor, vec3(UNDERGROUND_FOG_BRIGHTNESS), darkenAmount);
		
	#elif defined NETHER
		
		// must stay the same as in /utils/getSkyColor.glsl
		fogColor = fogColor;
		fogColor = mix(vec3(getLum(fogColor)), fogColor, NETHER_SKY_FOG_SATURATION);
		fogColor = NETHER_SKY_BASE_COLOR + NETHER_SKY_FOG_INFLUENCE * fogColor;
		
	#elif defined END
		
		fogColor = vec3(0.4, 0.2, 0.5);
		
	#endif
	
	if (isEyeInWater == 1) {
		fogColor = WATER_FOG_COLOR;
	} else if (isEyeInWater == 2) {
		fogColor = LAVA_FOG_COLOR;
	} else if (isEyeInWater == 3) {
		fogColor = POWDERED_SNOW_FOG_COLOR;
	}
	
	return fogColor;
	
}



#endif
