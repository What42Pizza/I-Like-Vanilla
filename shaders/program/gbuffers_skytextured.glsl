#ifdef FIRST_PASS
	in_out vec2 texcoord;
	in_out vec3 skyColor;
	#ifdef END
		in_out vec3 glcolor;
	#endif
#endif



#ifdef FSH

void main() {
	
	vec3 color = texture2D(MAIN_TEXTURE, texcoord).rgb;
	
	#ifdef OVERWORLD
		
		// increase opacity (the color is literally just added to the buffer, not mixed, so you have to increase the brightness for "more opacity")
		color = 1.0 - color;
		color *= color;
		if (sunPosition.z < 0.0) {
			color *= color; // apply extra brightness to sun
		}
		color = 1.0 - color;
		
		#include "/import/sunPosition.glsl"
		color *= sunPosition.z < 0.0 ? SUN_BRIGHTNESS : MOON_BRIGHTNESS;
		#include "/import/rainStrength.glsl"
		color *= 1.0 - 0.6 * rainStrength;
		
	#endif
	
	
	#ifdef END
		color *= 0.25;
	#endif
	
	
	/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(color, 1.0);
	
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
