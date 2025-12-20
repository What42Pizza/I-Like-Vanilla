in_out vec2 lmcoord;
flat in_out vec4 glcolor;
flat in_out vec2 encodedNormal;



#ifdef FSH

void main() {
	vec4 color = glcolor;
	color.a = 0.5 + 0.5 * color.a;
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(0.0, 0.3),
		encodedNormal
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
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color;
	encodedNormal = encodeNormal(gbufferModelView[1].xyz);
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
		gl_Position.z -= 0.0001;
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
}

#endif
