#ifdef FIRST_PASS
	in_out vec3 color;
#endif



#ifdef FSH

void main() {
	/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif





#ifdef VSH

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	gl_Position = ftransform();
	bool isStar = gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0 && gl_Color.r < 0.51; // vanilla Star Detection by Builderb0y
	if (!isStar) {
		gl_Position = vec4(1.0);
		return;
	}
	
	
	#ifdef OVERWORLD
		#if DARKEN_STARS_NEAR_BLOCKLIGHT == 1
			#include "/import/eyeBrightnessSmooth.glsl"
			float blockBrightness = eyeBrightnessSmooth.x / 240.0;
			blockBrightness = min(blockBrightness * 8.0, 1.0);
			float starsBrightness = mix(STARS_BRIGHTNESS, DARKENED_STARS_BRIGHTNESS, blockBrightness);
		#else
			const float starsBrightness = STARS_BRIGHTNESS;
		#endif
		#include "/import/ambientMoonPercent.glsl"
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
		float nightPercent = ambientMoonPercent + max(ambientSunrisePercent + ambientSunsetPercent, 0.0);
		color = vec3(gl_Color.rgb * starsBrightness * float(isStar) * nightPercent);
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
