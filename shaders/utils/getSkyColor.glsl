#ifndef INCLUDE_GET_SKY_COLOR
#define INCLUDE_GET_SKY_COLOR



vec3 getSkyColor(vec3 viewDir, const bool includeLightning) {
	vec3 skyColor;
	
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
		
		float skyMixFactor = dayPercent;
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		skyColor = mix(NIGHT_COLOR, DAY_COLOR, skyMixFactor);
		skyColor = mix(skyColor, vec3(0.05 + dayPercent * 0.4), inPaleGarden);
		upDot = max(upDot, 0.0);
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, skyMixFactor);
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			horizonColor *= 1.0 - 0.4 * sunriseSunsetPercent;
			skyColor *= 1.0 - 0.4 * sunriseSunsetPercent;
		#endif
		horizonColor = mix(horizonColor, vec3(0.1 + 0.25 * dayPercent), inPaleGarden);
		float horizonAmount = 1.0 - upDot;
		horizonAmount *= horizonAmount;
		horizonAmount *= horizonAmount;
		horizonAmount = 1.0 - horizonAmount;
		skyColor = mix(horizonColor, skyColor, horizonAmount);
		
		float sunDot = dot(viewDir, sunPosition * 0.01) * 0.5 + 0.5;
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			sunDot *= sunDot;
		#endif
		sunDot *= 1.0 - upDot;
		sunDot *= 1.0 - (1.0 - sunriseSunsetPercent) * (1.0 - sunriseSunsetPercent);
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		skyColor = mix(skyColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		float rainAmount = rainStrength * 0.7;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		skyColor = mix(skyColor, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		skyColor *= 2.0/3.0;
		skyColor = min(skyColor, 1.0);
		skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
		skyColor *= 3.0/2.0 * 1.2;
		skyColor *= 0.3 + 0.7 * dayPercent;
		
		if (includeLightning) {
			skyColor += lightningFlashAmount * LIGHTNING_BRIGHTNESS * 0.25;
		}
		
		float eyeBrightness = eyeBrightnessSmooth.y / 240.0;
		float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightness);
		float darkenMult = clamp(upDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
		darkenMult = 1.0 - darkenMult;
		darkenMult *= uint(isEyeInWater == 0);
		skyColor = mix(skyColor, vec3(UNDERGROUND_FOG_BRIGHTNESS), darkenMult);
		
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			skyColor *= 0.75;
			skyColor = mix(vec3(getLum(skyColor)), skyColor, 0.75);
		#endif
		
		#if AUTO_EXPOSURE_ENABLED == 1
			skyColor *= 0.9;
		#endif
		
	#elif defined NETHER
		
		skyColor = fogColor;
		skyColor = mix(vec3(getLum(skyColor)), skyColor, NETHER_SKY_FOG_SATURATION);
		skyColor = NETHER_SKY_BASE_COLOR + NETHER_SKY_FOG_INFLUENCE * skyColor;
		
	#elif defined END
		
		#if CUSTOM_END_SKYBOX == 0
			vec3 worldDir = mat3(gbufferModelViewInverse) * viewDir;
			float brightness = valueNoise3(worldDir * 700.0);
			skyColor = mix(END_SKY_COLOR * 0.5, END_STATIC_COLOR, brightness * 0.35);
		#elif CUSTOM_END_SKYBOX == 1
			skyColor = vec3(0.0);
		#endif
		
	#endif
	
	if (isEyeInWater == 1) {
		skyColor = mix(skyColor, WATER_FOG_COLOR, 0.75);
	} else if (isEyeInWater == 2) {
		skyColor = mix(skyColor, LAVA_FOG_COLOR, 0.75);
	} else if (isEyeInWater == 3) {
		skyColor = mix(skyColor, POWDERED_SNOW_FOG_COLOR, 0.75);
	}
	
	return skyColor;
	
}



#endif
