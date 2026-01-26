in_out vec2 texcoord;



#ifdef FSH

void main() {
	
	vec4 color = texture2D(texture, texcoord);
	#ifdef CUSTOM_SKYBOX
		color.rgb *= color.rgb;
	#endif
	
	
	#if defined OVERWORLD && CUSTOM_OVERWORLD_SKYBOX == 0
		
		// increase opacity (the color is literally just added to the buffer, not mixed, so you have to increase the brightness for "more opacity")
		color.rgb = 1.0 - color.rgb;
		if (sunPosition.z < 0.0) {
			color.rgb = pow(color.rgb, vec3((SUN_OPACITY - 1.0) * 0.5 + 1.0));
		} else {
			color.rgb = pow(color.rgb, vec3((MOON_OPACITY - 1.0) * 0.5 + 1.0));
		}
		color.rgb = 1.0 - color.rgb;
		
		color.rgb *= sunPosition.z < 0.0 ? SUN_BRIGHTNESS : MOON_BRIGHTNESS;
		color.rgb *= 1.0 - 0.6 * rainStrength;
		
	#endif
	
	
	#if defined END && CUSTOM_END_SKYBOX == 0
		discard;
	#endif
	
	
	/* DRAWBUFFERS:5 */
	gl_FragData[0] = color;
	
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
