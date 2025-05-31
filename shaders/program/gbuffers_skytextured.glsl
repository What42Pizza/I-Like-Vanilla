#ifdef FIRST_PASS
	in_out vec2 texcoord;
	in_out vec3 skyColor;
	#ifdef END
		in_out vec3 glcolor;
	#endif
#endif



#ifdef FSH

void main() {
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord);
	
	#ifdef OVERWORLD
		albedo.rgb = 1.0 - albedo.rgb;
		albedo.rgb *= albedo.rgb;
		if (sunPosition.z < 0.0) {
			albedo.rgb *= albedo.rgb; // apply extra brightness to sun
		}
		albedo.rgb = 1.0 - albedo.rgb;
	#endif
	
	#ifdef END
		albedo.rgb *= 0.3;
	#endif
	
	
	#ifdef OVERWORLD
		#include "/import/sunPosition.glsl"
		albedo.rgb *= sunPosition.z < 0.0 ? SUN_BRIGHTNESS : MOON_BRIGHTNESS;
		albedo.rgb *= 1.0 - skyColor;
		#include "/import/rainStrength.glsl"
		albedo.rgb *= 1.0 - 0.6 * rainStrength;
	#endif
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		1.0
	);
	
}

#endif



#ifdef VSH

#define SKIP_SKY_NOISE
#include "/utils/getSkyColor.glsl"

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
	
	
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	skyColor = getSkyColor(normalize(viewPos), true  ARGS_IN);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if TAA_ENABLED == 1 && !defined END
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
