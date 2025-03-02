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
		SKY_FOG_DAY_COLOR * ambientSunPercent +
		SKY_FOG_NIGHT_COLOR * ambientMoonPercent +
		SKY_FOG_SUNRISE_COLOR * ambientSunrisePercent +
		SKY_FOG_SUNSET_COLOR * ambientSunsetPercent;
	#include "/import/sunAngle.glsl"
	float skyMixingValue = sunAngle * 4.0 - (sunAngle < 0.5 ? 1.0 : 3.0);
	skyMixingValue *= skyMixingValue;
	skyMixingValue *= skyMixingValue;
	if (sunAngle < 0.5) skyMixingValue = 1.0 - skyMixingValue;
	vec3 skyColor = mix(SKY_NIGHT_COLOR, SKY_DAY_COLOR, skyMixingValue);
	
	#include "/import/gbufferModelView.glsl"
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	vec3 upPos = gbufferModelView[1].xyz;
	vec3 viewPos = endMat(gbufferProjectionInverse * vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0));
	float upDot = dot(normalize(viewPos), upPos);
	//upDot = sqrt(max(upDot, 0.0));
	skyColor = mix(skyFogColor, skyColor, max(upDot, 0.0));
	
	#if DARKEN_SKY_UNDERGROUND == 1
		skyColor *= getHorizonMultiplier(ARG_IN);
	#endif
	
	return skyColor;
}



#endif
