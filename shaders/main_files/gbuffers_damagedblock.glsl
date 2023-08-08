varying vec2 texcoord;

// this file is to stop block breaking from having shadows



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	/* DRAWBUFFERS:02 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
	gl_FragData[1] = color;
}

#endif



#ifdef VSH

#include "/lib/taa_jitter.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	gl_Position = ftransform();
	#ifdef TAA_ENABLED
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif
	
}

#endif
