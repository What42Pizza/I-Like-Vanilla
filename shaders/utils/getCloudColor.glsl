vec3 getCloudColor(float brightness) {
	brightness += 0.2 * dayPercent;
	vec3 cloudColor =
		CLOUD_DAY_COLOR * ambientSunPercent
		+ CLOUD_NIGHT_COLOR * 0.5 * ambientMoonPercent
		+ CLOUD_SUNRISE_COLOR * ambientSunrisePercent
		+ CLOUD_SUNSET_COLOR * ambientSunsetPercent;
	cloudColor = mix(cloudColor, vec3(0.1 + 0.5 * dayPercent), inPaleGarden * 0.6);
	#if AUTO_EXPOSURE_ENABLED == 1
		cloudColor *= 0.9;
	#endif
	cloudColor *= mix(CLOUD_BOTTOM_TINT * (0.1 + 0.9 * dayPercent - 0.25 * rainStrength), vec3(1.0), brightness);
	cloudColor *= mix(vec3(1.0), CLOUD_WEATHER_TINT, rainStrength);
	return cloudColor;
}
