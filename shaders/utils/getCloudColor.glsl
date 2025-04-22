vec3 getCloudColor(vec3 normal  ARGS_OUT) {
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientMoonPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	vec3 cloudColor =
		CLOUD_DAY_COLOR * ambientSunPercent
		+ CLOUD_NIGHT_COLOR * ambientMoonPercent
		+ CLOUD_SUNRISE_COLOR * ambientSunrisePercent
		+ CLOUD_SUNSET_COLOR * ambientSunsetPercent;
	#include "/import/sunPosition.glsl"
	#include "/import/moonPosition.glsl"
	#include "/import/dayPercent.glsl"
	float brightness = 0.3
		+ 0.15 * dot(normal, normalize(sunPosition)) * dayPercent
		+ 0.1 * dot(normal, normalize(moonPosition)) * (1.0 - dayPercent)
		+ 0.5 * dayPercent;
	return mix(vec3(0.0, 0.1, 0.3) * (0.1 + 0.9 * dayPercent), cloudColor, brightness);
}
