#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb * 2.0;
	
	
	
	// ======== BLOOM CALCULATIONS ======== //
	
	#if BLOOM_ENABLED == 1
		addBloom(color  ARGS_IN);
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
