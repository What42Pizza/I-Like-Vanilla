#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec3 glcolor;
	in_out vec3 viewPos;
	flat in_out vec3 normal;
	flat in_out int materialId;
	
	flat in_out vec3 shadowcasterColor;
	
	#if WAVING_WATER_SURFACE_ENABLED == 1 || defined DISTANT_HORIZONS
		in_out vec3 playerPos;
	#endif
	#if BORDER_FOG_ENABLED == 1
		in_out float fogAmount;
	#endif
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

#if WAVING_WATER_SURFACE_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/applyFog.glsl"
#endif

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if TEMPORAL_FILTER_ENABLED == 1
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y)) * 0.95;
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 10 - 8 * dither) discard;
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	color.rgb *= glcolor;
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (materialId == 7) {
		
		color.rgb = mix(vec3(getColorLum(color.rgb)), color.rgb, 0.8);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		
		// waving water normals
		#if WAVING_WATER_SURFACE_ENABLED == 1
			#include "/import/frameTimeCounter.glsl"
			#include "/import/cameraPosition.glsl"
			vec3 randomPoint = simplexNoise3From4(vec4((playerPos + cameraPosition) / WAVING_WATER_SCALE, frameTimeCounter * WAVING_WATER_SPEED));
			randomPoint = normalize(randomPoint);
			randomPoint += simplexNoise3From4(vec4((playerPos + cameraPosition) / WAVING_WATER_SCALE / 0.2, frameTimeCounter * WAVING_WATER_SPEED * 2.0)) * 0.5;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y);
			randomPoint = mix(normal, randomPoint, wavingSurfaceAmount);
			randomPoint = normalize(randomPoint);
			normal = normalize(normal + randomPoint * 0.05 * WAVING_WATER_NORMAL_AMOUNT * dot(normal, normalize(viewPos)));
			float fresnel = dot(-randomPoint, normalize(viewPos));
			color.rgb *= 1.0 - fresnel * fresnel * WAVING_WATER_FRESNEL_MULT * 0.5;
		#endif
		
		
		color.a = (1.0 - WATER_TRANSPARENCY);
		
	}
	
	
	// main lighting
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, viewPos, normal  ARGS_IN);
	
	
	// fog
	#if BORDER_FOG_ENABLED == 1
		applyFog(color.rgb, fogAmount  ARGS_IN);
	#endif
	
	
	float reflectiveness = ((materialId - materialId % 100) / 100) * 0.15;
	if (materialId == 7) reflectiveness = mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y);
	
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		reflectiveness,
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterColor.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color.rgb;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	normal = gl_NormalMatrix * gl_Normal;
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	materialId %= 1000;
	
	shadowcasterColor = getShadowcasterColor(ARG_IN);
	
	
	#if !(WAVING_WATER_SURFACE_ENABLED == 1 || defined DISTANT_HORIZONS)
		vec3 playerPos;
	#endif
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex));
	
	#if PHYSICALLY_WAVING_WATER_ENABLED == 1
		if (materialId == 7) {
			float wavingAmount = mix(PHYSICALLY_WAVING_WATER_AMOUNT_UNDERGROUND, PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE, lmcoord.y);
			#ifdef DISTANT_HORIZONS
				#include "/import/far.glsl"
				float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			playerPos += cameraPosition;
			playerPos.y += sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.03 * wavingAmount;
			playerPos.y += sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.02 * wavingAmount;
			playerPos -= cameraPosition;
		}
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if BORDER_FOG_ENABLED == 1
		fogAmount = getFogAmount(playerPos  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
