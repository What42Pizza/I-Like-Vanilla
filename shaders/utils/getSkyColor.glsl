#ifndef INCLUDE_GET_SKY_COLOR
#define INCLUDE_GET_SKY_COLOR



vec3 getSkyColor(vec3 viewDir, const bool includeLightning) {
	vec3 skyColorOut;
	
	#ifdef OVERWORLD
		
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.75;
			const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.75;
			const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR;
			const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR;
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.8;
			const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.3;
			const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.8;
			const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
			const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR * 0.75;
			const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR * 0.75;
		#endif
		
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		skyColorOut = mix(NIGHT_COLOR, DAY_COLOR, dayPercent);
		skyColorOut = mix(skyColorOut, vec3(0.05 + dayPercent * 0.4), inPaleGarden);
		upDot = max(upDot, 0.0);
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, dayPercent);
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			horizonColor *= 1.0 - 0.4 * skySunriseSunsetPercent;
			skyColorOut *= 1.0 - 0.4 * skySunriseSunsetPercent;
		#endif
		horizonColor = mix(horizonColor, vec3(0.1 + 0.25 * dayPercent), inPaleGarden);
		float horizonAmount = 1.0 - upDot;
		#if HORIZON_FADE_STRENGTH > 0
			horizonAmount *= horizonAmount;
		#endif
		#if HORIZON_FADE_STRENGTH > 1
			horizonAmount *= horizonAmount;
		#endif
		#if HORIZON_FADE_STRENGTH > 2
			horizonAmount *= horizonAmount;
		#endif
		#if HORIZON_FADE_STRENGTH > 3
			horizonAmount *= horizonAmount;
		#endif
		#if HORIZON_FADE_STRENGTH > 4
			horizonAmount *= horizonAmount;
		#endif
		#if HORIZON_FADE_STRENGTH > 5
			horizonAmount *= horizonAmount;
		#endif
		#if USE_VANILLA_FOG_COLOR == 1
			horizonAmount = 1.0 - 0.5 * upDot;
			horizonAmount = pow(horizonAmount, 2.5);
		#endif
		#if USE_VANILLA_SKY_COLOR == 1
			skyColorOut = skyColor * skyColor * sqrt(skyColor) * 0.7;
		#endif
		#if USE_VANILLA_FOG_COLOR == 1
			horizonColor = pow(fogColor, vec3(1.2)) * (1.25 - 0.35 * dayPercent);
		#endif
		skyColorOut = mix(skyColorOut, horizonColor, horizonAmount);
		
		float sunDot = dot(viewDir, sunPosition * 0.01) * 0.5 + 0.5;
		#if CUSTOM_OVERWORLD_SKYBOX == 0
			sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		#elif CUSTOM_OVERWORLD_SKYBOX == 1
			sunDot *= sunDot;
		#endif
		float upDotForSS = 1.0 - (1.0 - upDot) * (1.0 - upDot);
		sunDot *= percentThrough(upDotForSS * (1.0 - SUNRISE_SUNSET_TOP_HEIGHT * 0.5), 1.0, SUNRISE_SUNSET_BOTTOM_HEIGHT);
		sunDot *= skySunriseSunsetPercent;
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		skyColorOut = mix(skyColorOut, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		float rainAmount = rainStrength * SKY_WEATHER_DESATURATION;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		skyColorOut = mix(skyColorOut, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		skyColorOut *= 2.0/3.0;
		skyColorOut = min(skyColorOut, 1.0);
		skyColorOut = 1.0 - (skyColorOut - 1.0) * (skyColorOut - 1.0);
		skyColorOut *= 3.0/2.0 * 1.2;
		skyColorOut *= 0.3 + 0.7 * dayPercent;
		
		if (includeLightning) {
			skyColorOut += lightningFlashAmount * LIGHTNING_BRIGHTNESS * 0.25;
		}
		
		vec3 playerDir = mat3(gbufferModelViewInverse) * viewDir;
		playerDir /= max(length(playerDir.xz), abs(playerDir.y * 1.25));
		float cameraPositionY = mix(cameraPosition.y, max(cameraPosition.y, 56.0), eyeBrightnessSmooth.y / 240.0);
		float yPos = playerDir.y * far + cameraPositionY;
		float darkenAmount = percentThrough(yPos, 56.0, 56.0 - far / 4.0);
		#if UNDERGROUND_FOG_COLOR_TYPE == 1
			#define FOG_COLOR fogColor
		#elif UNDERGROUND_FOG_COLOR_TYPE == 2
			#define FOG_COLOR vec3(UNDERGROUND_FOG_BRIGHTNESS * 0.5)
		#endif
		skyColorOut = mix(skyColorOut, FOG_COLOR, darkenAmount);
		
		#if CUSTOM_OVERWORLD_SKYBOX == 1
			skyColorOut *= CUSTOM_OVERWORLD_SKY_BRIGHTNESS;
			skyColorOut = mix(vec3(getLum(skyColorOut)), skyColorOut, CUSTOM_OVERWORLD_SKY_SATURATION);
		#endif
		
		#if AUTO_EXPOSURE_ENABLED == 1
			skyColorOut *= 0.9;
		#endif
		
	#elif defined NETHER
		
		// important: this must stay the same as in /utils/getFogColor.glsl
		skyColorOut = fogColor;
		skyColorOut = mix(vec3(getLum(skyColorOut)), skyColorOut, NETHER_SKY_FOG_SATURATION);
		skyColorOut = NETHER_SKY_BASE_COLOR + NETHER_SKY_FOG_INFLUENCE * skyColorOut;
		skyColorOut *= NETHER_SKY_TINT_COLOR;
		
	#elif defined END
		
		#if CUSTOM_END_SKYBOX == 0
			vec3 worldDir = mat3(gbufferModelViewInverse) * viewDir;
			float brightness = 0.0;
			brightness += valueNoise(worldDir * 90.0 * 0.125) * 0.5;
			brightness += valueNoise(worldDir * 90.0 * 0.25 ) * 0.25;
			brightness += valueNoise(worldDir * 90.0 * 0.5  ) * 0.125;
			brightness += valueNoise(worldDir * 90.0 * 1.0  ) * 0.0625;
			skyColorOut = mix(END_SKY_COLOR * 0.5, END_STATIC_COLOR, brightness * 0.5);
		#elif CUSTOM_END_SKYBOX == 1
			skyColorOut = vec3(0.0);
		#endif
		
	#endif
	
	// important: this must stay the same as in /utils/getFogColor.glsl
	if (isEyeInWater == 1) {
		skyColorOut = fogColor;
		skyColorOut = mix(vec3(getLum(skyColorOut)), skyColorOut, WATER_VANILLA_FOG_SATURATION);
		skyColorOut = WATER_FOG_BASE_COLOR + WATER_VANILLA_FOG_INFLUENCE * skyColorOut;
		skyColorOut *= WATER_FOG_TINT_COLOR;
	} else if (isEyeInWater == 2) {
		skyColorOut = mix(skyColorOut, LAVA_FOG_COLOR * (0.25 + 0.75 * max(dayPercent, eyeBrightnessSmooth.x / 240.0)), 0.75);
	} else if (isEyeInWater == 3) {
		skyColorOut = mix(skyColorOut, POWDERED_SNOW_FOG_COLOR * (0.25 + 0.75 * max(dayPercent, eyeBrightnessSmooth.x / 240.0)), 0.75);
	}
	
	skyColorOut *= 1.0 - blindness;
	skyColorOut *= 1.0 - darknessFactor;
	
	return skyColorOut;
	
}



#endif
