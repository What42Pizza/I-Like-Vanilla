#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec3 glcolor;
	flat in_out vec2 normal;
	in_out float blockDepth;
	
#endif





#ifdef FSH

#ifdef FIRST_PASS
	float percentThrough(float v, float low, float high) {
		return clamp((v - low) / (high - low), 0.0, 1.0);
	}
#endif

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * vec4(glcolor, 1.0);
	
	float transparency = percentThrough(blockDepth, 1.0, 1.4);
	color.a *= (transparency - 1.0) * NEARBY_PARTICLE_TRANSPARENCY + 1.0;
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	if (color.a < dither) discard;
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(normal),
		packVec2(0.0, 0.0),
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

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
	glcolor = gl_Color.rgb * 1.2;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	blockDepth = length(playerPos);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.0) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	doVshLighting(blockDepth  ARGS_IN);
	
}

#endif
