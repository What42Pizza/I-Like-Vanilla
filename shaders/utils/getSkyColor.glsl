#undef INCLUDE_GET_SKY_COLOR

#if defined FIRST_PASS && !defined GET_SKY_COLOR_FIRST_FINISHED
	#define INCLUDE_GET_SKY_COLOR
	#define GET_SKY_COLOR_FIRST_FINISHED
#endif
#if defined SECOND_PASS && !defined GET_SKY_COLOR_SECOND_FINISHED
	#define INCLUDE_GET_SKY_COLOR
	#define GET_SKY_COLOR_SECOND_FINISHED
#endif



#ifdef INCLUDE_GET_SKY_COLOR



#if DARKEN_SKY_UNDERGROUND == 1
	float getHorizonMultiplier(float upDot  ARGS_OUT) {
		#ifdef OVERWORLD
			#include "/import/horizonAltitudeAddend.glsl"
			#include "/import/eyeBrightnessSmooth.glsl"
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
			return clamp(upDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
		#else
			return 1.0;
		#endif
	}
#endif

vec3 getSkyColor(vec3 viewDir, const bool darkenUndergroundSky  ARGS_OUT) {
	
	const vec3 DAY_COLOR = SKY_DAY_COLOR * SKY_DAY_COLOR;
	const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * SKY_NIGHT_COLOR;
	const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * SKY_HORIZON_DAY_COLOR;
	const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * SKY_HORIZON_NIGHT_COLOR;
	const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR * SKY_HORIZON_SUNRISE_COLOR;
	const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR * SKY_HORIZON_SUNSET_COLOR;
	
	#include "/import/dayPercent.glsl"
	float skyMixFactor = dayPercent;
	skyMixFactor *= skyMixFactor;
	#include "/import/gbufferModelView.glsl"
	float upDot = dot(viewDir, gbufferModelView[1].xyz);
	#include "/utils/var_rng.glsl"
	vec3 skyColor = mix(NIGHT_COLOR * 0.2, DAY_COLOR, skyMixFactor);
	upDot += randomFloat(rng) * 0.05 * (0.8 - getColorLum(skyColor));
	upDot = max(upDot, 0.0) + 0.01;
	vec3 horizonColor = mix(HORIZON_NIGHT_COLOR * 0.2, HORIZON_DAY_COLOR, skyMixFactor);
	skyColor = mix(horizonColor, skyColor, sqrt(upDot));
	
	#include "/import/sunPosition.glsl"
	float sunDot = dot(viewDir, normalize(sunPosition)) * 0.5 + 0.5;
	sunDot *= 1.0 - 0.8 * upDot;
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	sunDot *= (ambientSunrisePercent + ambientSunsetPercent) * (ambientSunrisePercent + ambientSunsetPercent);
	#include "/import/sunAngle.glsl"
	skyColor = mix(skyColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
	
	#include "/import/rainStrength.glsl"
	float rainAmount = 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
	rainAmount *= rainStrength * 0.8;
	skyColor = mix(skyColor, vec3(0.9, 0.95, 1.0) * dayPercent * 0.15, rainAmount);
	
	skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
	
	#if DARKEN_SKY_UNDERGROUND == 1
		if (darkenUndergroundSky) {
			skyColor *= getHorizonMultiplier(upDot  ARGS_IN);
		}
	#endif
	
	return clamp(skyColor, 0.0, 1.0);
}



#endif
