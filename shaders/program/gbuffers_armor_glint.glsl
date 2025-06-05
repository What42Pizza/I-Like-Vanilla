#ifdef FIRST_PASS
	in_out vec2 texcoord;
	in_out vec4 glcolor;
#endif





#ifdef FSH

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	
	/* DRAWBUFFERS:0 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	
}

#endif





#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	//glcolor.a = 0.5 + 0.5 * glcolor.a;
	glcolor.a *= 3.0;
	
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.0) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
