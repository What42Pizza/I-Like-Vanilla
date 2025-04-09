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
	float getHorizonMultiplier(ARG_OUT) {
		#ifdef OVERWORLD
			
			#include "/import/invViewSize.glsl"
			#include "/import/gbufferProjectionInverse.glsl"
			#include "/import/upPosition.glsl"
			#include "/import/horizonAltitudeAddend.glsl"
			#include "/import/eyeBrightnessSmooth.glsl"
			
			vec4 screenPos = vec4(gl_FragCoord.xy * invViewSize, gl_FragCoord.z, 1.0);
			vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
			float viewDot = dot(normalize(viewPos.xyz), normalize(upPosition));
			float altitudeAddend = min(horizonAltitudeAddend, 1.0 - 2.0 * eyeBrightnessSmooth.y / 240.0); // don't darken sky when there's sky light
			return clamp(viewDot * 5.0 - altitudeAddend * 8.0, 0.0, 1.0);
			
		#else
			return 1.0;
		#endif
	}
#endif

vec3 getSkyColor(ARG_OUT) {
	
	const float GAMMA_CORRECTION = 2.0;
	const vec3 DAY_COLOR = pow(SKY_DAY_COLOR, vec3(GAMMA_CORRECTION));
	const vec3 NIGHT_COLOR = pow(SKY_NIGHT_COLOR, vec3(GAMMA_CORRECTION));
	const vec3 HORIZON_DAY_COLOR = pow(SKY_HORIZON_DAY_COLOR, vec3(GAMMA_CORRECTION));
	const vec3 HORIZON_NIGHT_COLOR = pow(SKY_HORIZON_NIGHT_COLOR, vec3(GAMMA_CORRECTION));
	const vec3 HORIZON_SUNRISE_COLOR = pow(SKY_HORIZON_SUNRISE_COLOR, vec3(GAMMA_CORRECTION));
	const vec3 HORIZON_SUNSET_COLOR = pow(SKY_HORIZON_SUNSET_COLOR, vec3(GAMMA_CORRECTION));
	
	#include "/import/gbufferModelView.glsl"
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	vec3 upPos = gbufferModelView[1].xyz;
	vec3 viewPos = endMat(gbufferProjectionInverse * vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0));
	float upDot = dot(normalize(viewPos), upPos);
	#include "/utils/var_rng.glsl"
	
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	float skyMixFactor = ambientSunPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.75;
	skyMixFactor *= skyMixFactor;
	vec3 horizonColor = mix(HORIZON_NIGHT_COLOR * 0.02, HORIZON_DAY_COLOR, skyMixFactor);
	vec3 skyColor = mix(NIGHT_COLOR * 0.02, DAY_COLOR, skyMixFactor);
	upDot += randomFloat(rng) * 0.05 * (0.8 - getColorLum(skyColor));
	upDot = max(upDot, 0.0) + 0.01;
	skyColor = mix(horizonColor, skyColor, sqrt(upDot));
	
	#include "/import/sunPosition.glsl"
	float sunDot = dot(normalize(viewPos), normalize(sunPosition)) * 0.5 + 0.5;
	sunDot = (1.0 - upDot) * sunDot;
	sunDot *= (ambientSunrisePercent + ambientSunsetPercent) * (ambientSunrisePercent + ambientSunsetPercent);
	#include "/import/sunAngle.glsl"
	skyColor = mix(skyColor, sunAngle > 0.25 && sunAngle < 0.75 ? HORIZON_SUNSET_COLOR : HORIZON_SUNRISE_COLOR, sunDot);
	
	skyColor = pow(skyColor, vec3(1.0 / GAMMA_CORRECTION));
	skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
	
	#if DARKEN_SKY_UNDERGROUND == 1
		skyColor *= getHorizonMultiplier(ARG_IN);
	#endif
	
	return clamp(skyColor, 0.0, 1.0);
}



#endif
