#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec3 glcolor;
	flat in_out vec2 normal;
	flat in_out int materialId;
	
	#if defined DISTANT_HORIZONS || SHOW_DANGEROUS_LIGHT == 1
		in_out vec3 playerPos;
	#endif
	#if SHOW_DANGEROUS_LIGHT == 1
		in_out float isDangerousLight;
	#endif
	
#endif





#ifdef FSH

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if TEMPORAL_FILTER_ENABLED == 1
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 4 - 12 * dither) discard;
	#endif
	
	
	vec4 albedo = texture2D(MAIN_TEXTURE, texcoord) * vec4(glcolor, 1.0);
	if (albedo.a < 0.1) discard;
	albedo.rgb = smoothMin(albedo.rgb, vec3(1.0), 0.2);
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		#include "/import/cameraPosition.glsl"
		vec3 blockPos = fract(playerPos + cameraPosition);
		float centerDist = length(blockPos -= 0.5);
		albedo.rgb = mix(albedo.rgb, vec3(1.0, 0.0, 0.0), isDangerousLight * 0.3 * float(centerDist < 0.65));
	#endif
	
	
	float reflectiveness = ((materialId - materialId % 100) / 100) * 0.15 * mix(BLOCK_REFLECTION_AMOUNT_UNDERGROUND, BLOCK_REFLECTION_AMOUNT_SURFACE, lmcoord.y);
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(normal.x, normal.y),
		reflectiveness,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
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
	glcolor = mix(vec3(getColorLum(gl_Color.rgb)), gl_Color.rgb, FOLIAGE_SATURATION);
	glcolor *= 1.0 - (1.0 - gl_Color.a) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	materialId %= 1000;
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		isDangerousLight = float(gl_Normal.y > 0.9 && lmcoord.x < 0.5);
	#endif
	
	
	#if !(defined DISTANT_HORIZONS || SHOW_DANGEROUS_LIGHT == 1)
		vec3 playerPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	
	#if WAVING_ENABLED == 1
		applyWaving(playerPos  ARGS_IN);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
