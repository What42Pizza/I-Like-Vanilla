varying vec2 texcoord;

// this file is to stop block breaking from having shadows



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord);
	#ifdef DEBUG_OUTPUT_ENABLED
		vec3 debugOutput = vec3(0.0);
	#endif
	
	/* DRAWBUFFERS:0 */
	#ifdef DEBUG_OUTPUT_ENABLED
		color = vec4(debugOutput, 1.0);
	#endif
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#ifdef ISOMETRIC_RENDERING_ENABLED
	#include "/lib/isometric.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#ifdef ISOMETRIC_RENDERING_ENABLED
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef TAA_ENABLED
		#ifdef ISOMETRIC_RENDERING_ENABLED
			gl_Position.xy += taaOffset * 0.5;
		#else
			gl_Position.xy += taaOffset * gl_Position.w;
		#endif
	#endif
	
}

#endif
