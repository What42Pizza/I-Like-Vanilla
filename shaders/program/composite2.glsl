#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
	
	
	
	// ======== BLOOM CALCULATIONS ======== //
	
	#if BLOOM_ENABLED == 1
		float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 bloomAddition = getBloomAddition(depth  ARGS_IN);
		color += bloomAddition;
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
