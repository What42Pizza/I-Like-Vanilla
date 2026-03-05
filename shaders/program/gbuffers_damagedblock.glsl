in_out vec2 texcoord;



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	
	/* DRAWBUFFERS:0 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.5, 0.0, 0.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	
	gl_Position = viewToNdc(transform(gl_ModelViewMatrix, gl_Vertex.xyz));
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
}

#endif
