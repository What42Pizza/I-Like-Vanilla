#undef SHADOWS_ENABLED
#define SHADOWS_ENABLED 0

#ifdef FIRST_PASS
	
	in_out vec4 glcolor;
	in_out vec2 lmcoord;
	flat in_out vec3 normal;
	flat in_out int dhBlock;
	
	in_out vec3 playerPos;
	in_out vec3 viewPos;
	flat in_out vec3 shadowcasterColor;
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

#include "/utils/screen_to_view.glsl"
#if WAVING_WATER_SURFACE_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	float dither = bayer64(gl_FragCoord.xy);
	#if TEMPORAL_FILTER_ENABLED == 1
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	#include "/import/far.glsl"
	if (lengthCylinder < far - 10.0 - 8.0 * dither) discard;
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	#include "/import/invViewSize.glsl"
	vec3 realPos = screenToView(vec3(gl_FragCoord.xy * invViewSize, depth)  ARGS_IN);
	if (depth < 1.0 && dot(realPos, realPos) < dot(playerPos, playerPos)) discard;
	
	
	vec4 color = glcolor;
	float reflectiveness = getLum(color.rgb) * 1.5;
	reflectiveness = clamp(0.5 + (reflectiveness - 0.5) * 3.0, 0.0, 1.0);
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (dhBlock == DH_BLOCK_WATER) {
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 0.8);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		
		// waving water normals
		#if WAVING_WATER_SURFACE_ENABLED == 1
			#include "/import/frameTimeCounter.glsl"
			#include "/import/cameraPosition.glsl"
			vec3 randomPoint = simplexNoise3From4(vec4((playerPos + cameraPosition) / WAVING_WATER_SCALE, frameTimeCounter * WAVING_WATER_SPEED));
			randomPoint = normalize(randomPoint);
			randomPoint += simplexNoise3From4(vec4((playerPos + cameraPosition) / WAVING_WATER_SCALE / 0.2, frameTimeCounter * WAVING_WATER_SPEED * 2.0)) * 0.5;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y);
			randomPoint = mix(randomPoint, normal, wavingSurfaceAmount);
			randomPoint = normalize(randomPoint);
			normal = normalize(normal + randomPoint * 0.05 * WAVING_WATER_NORMAL_AMOUNT * dot(normal, normalize(viewPos)));
			float fresnel = dot(-randomPoint, normalize(viewPos));
			color.rgb *= 1.0 - fresnel * fresnel * WAVING_WATER_FRESNEL_MULT * 0.5;
		#endif
		
		
		#if WATER_DEPTH_BASED_TRANSPARENCY == 1
			color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
		#else
			color.a = 1.0 - (WATER_TRANSPARENCY_DEEP + WATER_TRANSPARENCY_SHALLOW) / 2.0;
		#endif
		
	}
	
	
	reflectiveness *= dhBlock == DH_BLOCK_WATER ? mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y) : 0.0;
	float specular_amount = dhBlock == DH_BLOCK_WATER ? 0.99 : 0.3;
	
	
	// main lighting
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, specular_amount, viewPos, normal  ARGS_IN);
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		packVec2(reflectiveness * 0.5, 0.0),
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

void main() {
	glcolor = gl_Color;
	glcolor.rgb = (glcolor.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	glcolor.rgb = mix(vec3(getLum(glcolor.rgb)), glcolor.rgb, 1.0 - TEXTURE_CONTRAST * 0.3);
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	normal = gl_NormalMatrix * gl_Normal;
	dhBlock = dhMaterialId;
	
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	if (dhBlock == DH_BLOCK_WATER) {
		playerPos.y -= 0.11213;
	}
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	shadowcasterColor = getShadowcasterColor(ARG_IN);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
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
