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



vec3 getSkyColor(vec3 viewDir  ARGS_OUT) {
	
	#ifdef OVERWORLD
		
		const vec3 DAY_COLOR = SKY_DAY_COLOR * 0.8 + 0.1;
		const vec3 NIGHT_COLOR = SKY_NIGHT_COLOR * 0.25;
		const vec3 HORIZON_DAY_COLOR = SKY_HORIZON_DAY_COLOR * 0.8 + 0.1;
		const vec3 HORIZON_NIGHT_COLOR = SKY_HORIZON_NIGHT_COLOR * 0.25;
		const vec3 HORIZON_SUNRISE_COLOR = SKY_HORIZON_SUNRISE_COLOR;
		const vec3 HORIZON_SUNSET_COLOR = SKY_HORIZON_SUNSET_COLOR;
		
		#include "/import/dayPercent.glsl"
		float skyMixFactor = dayPercent;
		#include "/import/gbufferModelView.glsl"
		float upDot = dot(viewDir, gbufferModelView[1].xyz);
		vec3 skyColor = mix(NIGHT_COLOR, DAY_COLOR, skyMixFactor);
		#include "/import/inPaleGarden.glsl"
		skyColor = mix(skyColor, vec3(0.05 + dayPercent * 0.35), inPaleGarden);
		#ifndef SKIP_SKY_NOISE
			#include "/utils/var_rng.glsl"
			upDot += randomFloat(rng) * 0.08 * (1.0 - 0.8 * sqrt(getLum(skyColor)));
		#endif
		upDot = clamp(upDot, 0.0, 1.0);// + 0.01;
		vec3 horizonColor = mix(HORIZON_NIGHT_COLOR, HORIZON_DAY_COLOR, skyMixFactor);
		horizonColor = mix(horizonColor, vec3(0.1 + 0.2 * dayPercent), inPaleGarden);
		skyColor = mix(horizonColor, skyColor, sqrt(upDot));
		
		#include "/import/sunPosition.glsl"
		float sunDot = dot(viewDir, normalize(sunPosition)) * 0.5 + 0.5;
		sunDot = 1.0 - (1.0 - sunDot) * (1.0 - sunDot);
		sunDot *= 1.0 - 0.8 * upDot;
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
		float sunriseSunsetPercent = ambientSunrisePercent + ambientSunsetPercent;
		sunDot *= sunriseSunsetPercent * sunriseSunsetPercent * (3.0 - 2.0 * sunriseSunsetPercent);
		sunDot *= 1.0 - 0.5 * inPaleGarden;
		#include "/import/sunAngle.glsl"
		skyColor = mix(skyColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
		
		#include "/import/rainStrength.glsl"
		float rainAmount = rainStrength * 0.7;
		rainAmount *= 1.0 - (1.0 - dayPercent) * (1.0 - dayPercent);
		skyColor = mix(skyColor, vec3(0.8, 0.9, 1.0) * SKY_WEATHER_BRIGHTNESS * dayPercent, rainAmount);
		
		skyColor = min(skyColor, 1.0);
		skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
		skyColor *= 1.2;
		skyColor *= 0.3 + 0.7 * dayPercent;
		
		#ifdef OVERWORLD
			#include "/import/horizonAltitudeAddend.glsl"
			#include "/import/eyeBrightnessSmooth.glsl"
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
			float darkenMult = clamp(upDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
			skyColor = mix(vec3(UNDERGROUND_FOG_BRIGHTNESS), skyColor, darkenMult);
		#endif
		
		return skyColor;
		
	#elif defined NETHER
		#include "/import/fogColor.glsl"
		vec3 skyColor = fogColor;
		skyColor += 0.15;
		return skyColor;
	#elif defined END
		return vec3(0.0);
	#endif
}



#endif
