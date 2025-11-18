in_out vec2 texcoord;
flat in_out float glcolor_alpha;
flat in_out vec2 normal;



#ifdef FSH

void main() {
	vec4 color = vec4(texture2D(MAIN_TEXTURE, texcoord).rgb, glcolor_alpha);
	
	color.rgb *= 1.5;
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(0.5, 1.0),
		pack_2x8(0.0, 0.0),
		normal
	);
	
}

#endif



#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	normal = encodeNormal(gl_NormalMatrix * vec3(0, -1, 0)); // probably bad way to disable shadows
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	glcolor_alpha = gl_Color.a;
	
}

#endif
