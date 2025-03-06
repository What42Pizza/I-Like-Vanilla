#ifdef FIRST_PASS
	in_out vec2 texcoord;
	#ifdef END
		in_out vec3 glcolor;
	#endif
#endif



#ifdef FSH

void main() {
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord);
	
	
	#ifdef OVERWORLD
		#include "/import/sunPosition.glsl"
		if (sunPosition.z < 0.0) {
			albedo.rgb *= SUN_BRIGHTNESS;
		} else {
			albedo.rgb *= MOON_BRIGHTNESS;
		}
	#endif
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		0.0,
		1.0
	);
	
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
	#ifdef END
		glcolor = gl_Color.rgb;
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if TAA_ENABLED == 1 && !defined END
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
