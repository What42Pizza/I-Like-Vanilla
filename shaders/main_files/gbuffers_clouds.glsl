// transfers

#ifdef FIRST_PASS
	
	varying vec2 texcoord;
	flat float glcolor;
	flat vec3 colorMult;
	#if HIDE_NEARBY_CLOUDS == 1
		varying float transparency;
	#endif
	
#endif

// includes

#ifdef FOG_ENABLED
	#include "/lib/fog.glsl"
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_BUFFER, texcoord) * glcolor;
	#ifdef DEBUG_OUTPUT_ENABLED
		vec4 debugOutput = vec4(0.0, 0.0, 0.0, color.a);
	#endif
	
	
	#if HIDE_NEARBY_CLOUDS == 0
		#define transparency CLOUD_TRANSPARENCY
	#endif
	color.a = transparency;
	
	
	color.rgb *= colorMult * 2.3;
	
	
	// bloom
	#if BLOOM_ENABLED == 1
		vec4 colorForBloom = color;
		colorForBloom.rgb *= sqrt(BLOOM_CLOUD_BRIGHTNESS);
	#endif
	
	
	// fog
	#if FOG_ENABLED == 1
		#if BLOOM_ENABLED == 1
			applyFog(color.rgb, colorForBloom.rgb  ARGS_IN);
		#else
			applyFog(color.rgb  ARGS_IN);
		#endif
	#endif
	
	
	
	// outputs
	
	#ifdef DEBUG_OUTPUT_ENABLED
		color = debugOutput;
	#endif
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
	
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:02 */
		gl_FragData[1] = colorForBloom;
	#endif
	
}

#endif



#ifdef VSH

#include "/utils/getSkyLight.glsl"
#include "/utils/getAmbientLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec3 skyLight = getSkyLight(ARG_IN);
	vec3 ambientLight = getAmbientLight(ARG_IN);
	colorMult = skyLight + ambientLight;
	//colorMult = mix(vec3(getColorLum(colorMult)), colorMult, vec3(1.0));
	colorMult = normalize(colorMult);
	
	#if ISOMETRIC_RENDERING_ENABLED == 1 || HIDE_NEARBY_CLOUDS == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 worldPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(worldPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	#if FOG_ENABLED == 1
		vec4 position = gl_Vertex;
		processFogVsh(position.xyz  ARGS_IN);
	#endif
	
	#if HIDE_NEARBY_CLOUDS == 1
		transparency = CLOUD_TRANSPARENCY * atan(length(worldPos) - 30.0) / PI + 0.5
	#endif
	
	glcolor = gl_Color.r;
	
}

#endif
