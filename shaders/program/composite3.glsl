#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if UNDERWATER_WAVINESS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	
	
	// ======== UNDERWATER WAVING ======== //
	
	#if UNDERWATER_WAVINESS_ENABLED == 1
		vec2 texcoord = texcoord;
		#include "/import/isEyeInWater.glsl"
		if (isEyeInWater == 1) {
			texcoord = (texcoord - 0.5) * 0.95 + 0.5;
			#include "/import/frameTimeCounter.glsl"
			vec3 simplexInput = vec3(
				texcoord * 6.0 * UNDERWATER_WAVINESS_SCALE,
				frameTimeCounter * 0.65 * UNDERWATER_WAVINESS_SPEED
			);
			texcoord += simplexNoise2From3(simplexInput) * 0.0015 * UNDERWATER_WAVINESS_AMOUNT;
		}
	#endif
	
	vec3 color = texture2D(MAIN_TEXTURE, texcoord).rgb * 2.0;
	
	
	
	/* DRAWBUFFERS:1 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
