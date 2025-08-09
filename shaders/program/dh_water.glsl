#undef SHADOWS_ENABLED
#define SHADOWS_ENABLED 0

#ifdef FIRST_PASS
	
	in_out vec4 glcolor;
	in_out vec2 lmcoord;
	in_out vec3 viewPos;
	in_out vec3 playerPos;
	flat in_out vec3 normal;
	flat in_out int dhBlock;
	
	flat in_out vec3 shadowcasterColor;
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"

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
	#include "/import/far.glsl"
	if (depth < 1.0 && length(playerPos) > toLinearDepth(depth  ARGS_IN) * far) discard;
	
	
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
			float fresnel = -dot(normal, normalize(viewPos));
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			vec3 noisePos = vec3(playerPos.xz + cameraPosition.xz, frameTimeCounter * WAVING_WATER_SPEED);
			noisePos.xy /= WAVING_WATER_SCALE * 2.0;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.02;
			float height = 1.0 - abs(simplexNoise(noisePos));
			float heightX = 1.0 - abs(simplexNoise(noisePos + vec3(0.01, 0.0, 0.0)));
			float heightZ = 1.0 - abs(simplexNoise(noisePos + vec3(0.0, 0.01, 0.0)));
			vec3 dirX = vec3(0.01, (height - heightX) * wavingSurfaceAmount, 0.0);
			vec3 dirZ = vec3(0.0, (height - heightZ) * wavingSurfaceAmount, 0.01);
			normal = cross(dirZ, dirX);
			normal = normalize(normal);
			//normal = tbn * vec3(-normal.x, normal.z, normal.y); // y = up -> z = up
			#include "/import/gbufferModelView.glsl"
			normal = mat3(gbufferModelView) * normal;
			float newFresnel = dot(normal, normalize(viewPos)); // should be inverted but it would be inverted again in the next step anyways
			color.rgb *= clamp(1.0 + WAVING_WATER_FRESNEL_MULT / wavingSurfaceAmount * 0.035 * (fresnel + newFresnel), 0.0, 1.5); // basically `color *= 1+(fresnel-newFresnel)` but it's weird because of settings and wavingSurfaceAmount
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
