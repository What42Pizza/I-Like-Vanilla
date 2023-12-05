// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	varying vec2 lmcoord;
	varying vec4 glcolor;
	
	varying vec3 normal;
	
#endif

// includes

#include "/lib/pre_lighting.glsl"
#include "/lib/basic_lighting.glsl"





#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	
	// main lighting
	
	color.rgb *= getBasicLighting(lmcoord.x, lmcoord.y  ARGS_IN);
	
	
	
	// bloom value
	
	#if BLOOM_ENABLED == 1
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_HAND_BRIGHTNESS);
	#endif
	
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:04 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(normal, 1.0);
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:0423 */
		gl_FragData[2] = colorForBloom;
		gl_FragData[3] = vec4(0.0, 0.0, 0.0, 1.0);
	#endif
	
	#if BLOOM_ENABLED == 1 && RAIN_REFLECTIONS_ENABLED == 0
		/* DRAWBUFFERS:042 */
		gl_FragData[2] = colorForBloom;
	#endif
	
	#if BLOOM_ENABLED == 0 && RAIN_REFLECTIONS_ENABLED == 1
		/* DRAWBUFFERS:043 */
		gl_FragData[2] = vec4(0.0, 0.0, 0.0, 1.0);
	#endif
	
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
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(worldPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	glcolor = gl_Color;
	
	normal = gl_NormalMatrix * gl_Normal;
	
	
	doPreLighting(ARG_IN);
	
}

#endif
