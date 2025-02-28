#ifdef FIRST_PASS
	varying vec2 texcoord;
	flat_inout float glcolor_alpha;
	varying vec2 normal;
#endif



#ifdef FSH

void main() {
	vec4 color = vec4(texture2D(MAIN_TEXTURE, texcoord).rgb, glcolor_alpha);
	
	color.rgb *= 1.1;
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.25),
		packVec2(normal),
		0.0,
		1.0
	);
	
}

#endif



#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#ifdef TAA_ENABLED
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#ifdef TAA_ENABLED
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	glcolor_alpha = gl_Color.a;
	
}

#endif
