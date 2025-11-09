vec3 getCloudColor(float brightness) {
	brightness += 0.2 * dayPercent;
	brightness *= 1.0 - 0.6 * CLOUD_WEATHER_DARKEN * rainStrength;
	vec3 cloudColor =
		CLOUD_DAY_COLOR * ambientSunPercent
		+ CLOUD_NIGHT_COLOR * 0.5 * ambientMoonPercent
		+ CLOUD_SUNRISE_COLOR * ambientSunrisePercent
		+ CLOUD_SUNSET_COLOR * ambientSunsetPercent;
	cloudColor = mix(cloudColor, vec3(0.1 + 0.5 * dayPercent), inPaleGarden * 0.6);
	return mix(vec3(0.0, 0.1, 0.3) * (0.1 + 0.9 * dayPercent), cloudColor, brightness);
}
