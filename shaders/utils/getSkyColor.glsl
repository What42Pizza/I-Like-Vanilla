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

#include "/utils/getShadowcasterColor.glsl"

vec3 getSkyColor(ARG_OUT) {
	
	#include "/import/ambientSunPercent.glsl"
	#include "/import/ambientMoonPercent.glsl"
	#include "/import/ambientSunrisePercent.glsl"
	#include "/import/ambientSunsetPercent.glsl"
	vec3 skyFogColor =
		SKY_HORIZON_DAY_COLOR * ambientSunPercent +
		SKY_HORIZON_NIGHT_COLOR * 0.25 * ambientMoonPercent +
		SKY_HORIZON_SUNRISE_COLOR * 0.75 * ambientSunrisePercent +
		SKY_HORIZON_SUNSET_COLOR * 0.75 * ambientSunsetPercent;
	vec3 skyColor = mix(SKY_NIGHT_COLOR * 0.25, SKY_DAY_COLOR, ambientSunPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.75);
	
	#include "/import/gbufferModelView.glsl"
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	vec3 upPos = gbufferModelView[1].xyz;
	vec3 viewPos = endMat(gbufferProjectionInverse * vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0));
	float upDot = dot(normalize(viewPos), upPos);
	#include "/utils/var_rng.glsl"
	upDot += randomFloat(rng) * 0.07 * (0.8 - getColorLum(skyFogColor));
	
	skyColor = mix(skyFogColor, skyColor, max(upDot, 0.0));
	skyColor = 1.0 - (skyColor - 1.0) * (skyColor - 1.0);
	
	#if DARKEN_SKY_UNDERGROUND == 1
		skyColor *= getHorizonMultiplier(ARG_IN);
	#endif
	
	return skyColor;
}



#endif
