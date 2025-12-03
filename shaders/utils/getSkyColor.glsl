#ifndef INCLUDE_GET_SKY_COLOR
#define INCLUDE_GET_SKY_COLOR



vec3 getSkyColor(vec3 viewDir, const bool includeLightning) {
	
	#ifdef OVERWORLD
		
		const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.8 + 0.1;
		const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.25;
		const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.8 + 0.1;
		const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
		const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR;
		const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR;
		
		float skyMixFactor = dayPercent;
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		vec3 skyColor = mix(NIGHT_COLOR, DAY_COLOR, skyMixFactor);
		skyColor = mix(skyColor, vec3(0.05 + dayPercent * 0.35), inPaleGarden);
		upDot = clamp(upDot, 0.0, 1.0);
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, skyMixFactor);
		horizonColor = mix(horizonColor, vec3(0.1 + 0.2 * dayPercent), inPaleGarden);
		skyColor = mix(horizonColor, skyColor, sqrt(upDot));
		
		float sunDot = dot(viewDir, normalize(sunPosition)) * 0.5 + 0.5;
		sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		sunDot *= 1.0 - 0.95 * upDot;
		float sunriseSunsetPercent = ambientSunrisePercent + ambientSunsetPercent;
		sunDot *= 1.0 - (1.0 - sunriseSunsetPercent) * (1.0 - sunriseSunsetPercent);
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		skyColor = mix(skyColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		float rainAmount = rainStrength * 0.7;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		skyColor = mix(skyColor, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		skyColor = min(skyColor, 1.0);
		skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
		skyColor *= 1.2;
		skyColor *= 0.3 + 0.7 * dayPercent;
		
		if (includeLightning) {
			uint time = uint(frameTimeCounter * 8.0);
			float amount = float(sin(time * 4u) > 0.0);
			skyColor += LIGHTNING_BRIGHTNESS * 0.25 * float(lightningBoltPosition.w > 0.001) * amount;
		}
		
		#ifdef OVERWORLD
			float eyeBrightness = eyeBrightnessSmooth.y / 240.0;
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightness);
			float darkenMult = clamp(upDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
			skyColor = mix(vec3(UNDERGROUND_FOG_BRIGHTNESS), skyColor, darkenMult);
		#endif
		
		return skyColor;
		
	#elif defined NETHER
		vec3 skyColor = fogColor;
		skyColor = mix(vec3(getLum(skyColor)), skyColor, 0.9);
		skyColor = mix(vec3(0.1), vec3(0.75), skyColor);
		return skyColor;
	#elif defined END
		return vec3(1.0);
	#endif
}



#endif
