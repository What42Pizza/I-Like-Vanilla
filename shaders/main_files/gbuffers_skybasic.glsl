#ifdef FIRST_PASS
	varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
#endif



#ifdef FSH

#include "/utils/getSkyColor.glsl"

void main() {
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	
	
	vec3 color = getSkyColor(ARG_IN);
	if (starData.a > 0.5) {
		#if DARKEN_STARS_NEAR_BLOCKLIGHT == 1
			#include "/import/eyeBrightnessSmooth.glsl"
			float blockBrightness = eyeBrightnessSmooth.x / 240.0;
			blockBrightness = min(blockBrightness * 10.0, 1.0);
			blockBrightness = mix(1.3, 0.2, blockBrightness);
			color = mix(color, starData.rgb, blockBrightness);
		#else
			color = starData.rgb;
		#endif
	}
	
	
	
	#if BLOOM_ENABLED == 1
		vec3 colorForBloom = color;
		colorForBloom *= sqrt(BLOOM_SKY_BRIGHTNESS);
	#endif
	
	
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = vec4(colorForBloom, 1.0);
	#endif
	
}

#endif





#ifdef VSH

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	
	gl_Position = ftransform();
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	
}

#endif
