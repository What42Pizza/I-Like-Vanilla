in_out vec2 texcoord;
flat in_out vec4 glcolor;
flat in_out vec2 encodedNormal;



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	
	color.rgb *= 1.5;
	float brightness = 0.5 + 0.5 * max(dayPercent, glcolor.a);
	
	/* DRAWBUFFERS:02 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.5, 1.0, 1.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(brightness, brightness),
		pack_2x8(0.0, 0.0),
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
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	encodedNormal = encodeNormal(gl_NormalMatrix * vec3(0, -1, 0)); // probably bad way to disable shadows
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	glcolor = gl_Color;
	
}

#endif
