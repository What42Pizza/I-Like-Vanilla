in_out vec3 color;



#ifdef FSH

void main() {
	/* DRAWBUFFERS:5 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		vec3 color = vec3(1.0, 1.0, 0.5);
	#endif
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	gl_Position = ftransform();
	bool isStar = gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0 && gl_Color.r < 0.51 && gl_Color.a < 0.8; // vanilla Star Detection by Builderb0y (edited by What42)
	#if CUSTOM_OVERWORLD_SKYBOX == 0
		if (!isStar) {
			gl_Position = vec4(1.0);
			return;
		}
	#endif
	
	
	#if defined OVERWORLD && CUSTOM_OVERWORLD_SKYBOX == 0
		#if DARKEN_STARS_NEAR_BLOCKLIGHT == 1
			float blockBrightness = eyeBrightnessSmooth.x / 240.0;
			blockBrightness = min(blockBrightness * 8.0, 1.0);
			float starsBrightness = mix(STARS_BRIGHTNESS, DARKENED_STARS_BRIGHTNESS, blockBrightness);
		#else
			const float starsBrightness = STARS_BRIGHTNESS;
		#endif
		float nightPercent = ambientMoonPercent + max(ambientSunrisePercent + ambientSunsetPercent, 0.0);
		color = vec3(gl_Color.rgb * starsBrightness * uint(isStar) * nightPercent);
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
}

#endif
