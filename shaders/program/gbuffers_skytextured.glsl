in_out vec2 texcoord;
#ifdef END
	in_out vec3 glcolor;
#endif



#ifdef FSH

void main() {
	
	vec3 color = texture2D(MAIN_TEXTURE, texcoord).rgb;
	
	
	#if defined OVERWORLD && CUSTOM_OVERWORLD_SKYBOX == 0
		
		// increase opacity (the color is literally just added to the buffer, not mixed, so you have to increase the brightness for "more opacity")
		color = 1.0 - color;
		if (sunPosition.z < 0.0) {
			color = pow(color, vec3((SUN_OPACITY - 1.0) * 0.5 + 1.0));
		} else {
			color = pow(color, vec3((MOON_OPACITY - 1.0) * 0.5 + 1.0));
		}
		color = 1.0 - color;
		
		color *= sunPosition.z < 0.0 ? SUN_BRIGHTNESS : MOON_BRIGHTNESS;
		color *= 1.0 - 0.6 * rainStrength;
		
	#endif
	
	
	#if defined END && CUSTOM_END_SKYBOX == 0
		discard;
	#endif
	
	
	/* DRAWBUFFERS:5 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

#define SKIP_SKY_NOISE
#include "/utils/getSkyColor.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
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
		vec3 playerPos = transform(gbufferModelViewInverse, mat3(gl_ModelViewMatrix) * gl_Vertex.xyz);
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if TAA_ENABLED == 1 && !defined END
		doTaaJitter(gl_Position.xy);
	#endif
	
	
}

#endif
