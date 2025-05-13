vec3 getCloudColor(float brightness  ARGS_OUT) {
	#include "/import/dayPercent.glsl"
	brightness += 0.2 * dayPercent;
	#include "/import/rainStrength.glsl"
	brightness *= 1.0 - 0.65 * rainStrength;
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientMoonPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	vec3 cloudColor =
		CLOUD_DAY_COLOR * ambientSunPercent
		+ CLOUD_NIGHT_COLOR * 0.5 * ambientMoonPercent
		+ CLOUD_SUNRISE_COLOR * ambientSunrisePercent
		+ CLOUD_SUNSET_COLOR * ambientSunsetPercent;
	return mix(vec3(0.0, 0.1, 0.3) * (0.1 + 0.9 * dayPercent), cloudColor, brightness) ;
}
