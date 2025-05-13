#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb;
	#if BLOOM_ENABLED == 1
		vec3 bloomColor = color;
	#endif
	
	
	
	// ======== AUTO EXPOSURE ======== //
	
	#if AUTO_EXPOSURE_ENABLED == 1
		#include "/import/eyeBrightnessSmooth.glsl"
		vec2 normalizedBrightness = eyeBrightnessSmooth / 240.0;
		#ifdef NETHER
			normalizedBrightness.y = 0.5;
		#elif defined END
			normalizedBrightness.y = 1.0;
		#endif
		normalizedBrightness *= vec2(0.5, 1.0); // weights
		float autoExposureAmount = max(normalizedBrightness.x, normalizedBrightness.y);
		color *= mix(AUTO_EXPOSURE_DARK_MULT, AUTO_EXPOSURE_BRIGHT_MULT, autoExposureAmount);
	#endif
	
	
	
	// ======== BLOOM FILTERING ======== //
	
	#if BLOOM_ENABLED == 1
		float bloomMult = getColorLum(bloomColor * vec3(2.0, 1.0, 0.4));
		bloomMult = (bloomMult - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		bloomMult = clamp(bloomMult, 0.0, 1.0);
		bloomColor *= bloomMult;
	#endif
	
	
	
	/* DRAWBUFFERS:1 */
	gl_FragData[0] = vec4(color, 1.0);
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:15 */
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
