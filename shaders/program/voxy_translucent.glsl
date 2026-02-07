layout(location = 0) out vec4 albedoOut;
layout(location = 1) out vec4 auxDataOut;

#include "/utils/screen_to_view.glsl"
#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"
vec3 shadowcasterLight = getShadowcasterLight();
#include "/lib/lighting/simple_fsh_lighting.glsl"



void voxy_emitFragment(VoxyFragmentParameters parameters) {
	
	// basics
	uint encodedData = uint(max(parameters.customId - (1u << 13u), 0) + (1u << 13u));
	#ifndef MODERN_BACKEND
		if (encodedData == 65535u) encodedData = 0u;
	#endif
	uint materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	vec3 screenPos = vec3(gl_FragCoord.xy * pixelSize, gl_FragCoord.z);
	vec3 viewPos = screenToViewVx(screenPos);
	vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
	
	
	// normals
	vec3 worldNormal = vec3(
		uint((parameters.face >> 1) == 2),
		uint((parameters.face >> 1) == 0),
		uint((parameters.face >> 1) == 1)
	);
	worldNormal *= float(parameters.face & 1) * 2.0 - 1.0;
	
	// foliage normals
	if ((encodedData & (3u << 14u)) >= (2u << 14u)) {
		worldNormal = vec3(0.0, 1.0, 0.0);
	}
	
	vec3 normal = mat3(gbufferModelView) * worldNormal;
	
	
	// lmcoord
	vec2 lmcoord = parameters.lightMap;
	adjustLmcoord(lmcoord);
	
	doVshLighting(lmcoord, viewPos, normal);
	
	
	// block-specific datas
	float reflectiveness;
	float specularness;
	vec3 glcolor = vec3(1.0);
	#define GET_REFLECTIVENESS
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/generated/blockDatas.glsl"
	
	
	// main color
	vec4 color = parameters.sampledColour;
	color.rgb = mix(color.rgb, color.rgb * color.rgb * (3.0 - 2.0 * color.rgb), TEXTURE_CONTRAST * 1.0);
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.08 - TEXTURE_CONTRAST * 0.3);
	color.rgb *= parameters.tinting.rgb;
	color.rgb *= glcolor;
	
	
	if (materialId == BLOCK_ID_WATER) {
		
		color.rgb *= 1.125;
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 0.825);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		vec3 viewDir = normalize(viewPos);
		float fresnel = -dot(normal, viewDir);
		
		
		#if WAVING_WATER_SURFACE_ENABLED == 1
			vec2 noisePos = (playerPos.xz + cameraPosition.xz) / WAVING_WATER_SCALE * 0.25;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.125;
			if (wavingSurfaceAmount > 0.00001) {
				float fresnelMult = mix(WAVING_WATER_FRESNEL_UNDERGROUND * 0.55, WAVING_WATER_FRESNEL_SURFACE * 0.55, lmcoord.y);
				float frameTimeCounter = frameTimeCounter * WAVING_WATER_SPEED;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				normal = vec3(0.0, 1.0, 0.0);
				normal.xz += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4;
				normal.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25;
				normal.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25;
				vec3 normalWithoutMult = mat3(gbufferModelView) * normalize(normal);
				normal.xz *= wavingSurfaceAmount;
				normal = mat3(gbufferModelView) * normalize(normal);
				fresnel = dot(normalWithoutMult, viewDir); // note: there should be made negative, but instead the next line does 1+fresnel instead of 1-fresnel
				color.rgb *= 1.0 + (fresnel + 0.5) * fresnelMult;
			}
		#endif
		
		
		if (isEyeInWater == 1) {
			color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
		} else {
			float blockDepth = length(viewPos);
			float opaqueBlockDepth = length(screenToViewVx(vec3(gl_FragCoord.xy * pixelSize, texelFetch(VX_DEPTH_BUFFER_OPAQUE, texelcoord, 0).r)));
			float waterDepth = opaqueBlockDepth - blockDepth;
			color.a = 1.0 - mix(WATER_TRANSPARENCY_DEEP, WATER_TRANSPARENCY_SHALLOW, 32.0 / (32.0 + waterDepth));
		}
		
		color.a *= 1.0 + fresnel * 0.125;
		
		// water needs to be more opaque in dark areas
		float alphaLift = max(lmcoord.x, lmcoord.y * dayPercent);
		alphaLift = sqrt(alphaLift);
		alphaLift = (1.0 - alphaLift) * (1.2 - screenBrightness);
		color.a = 1.0 - (1.0 - alphaLift) * (1.0 - color.a);
		
	}
	
	
	// main lighting
	doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, specularness, viewPos, normal);
	
	
	color.rgb *= 0.5;
	albedoOut = color;
	auxDataOut = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, 0.0),
		encodeNormal(normal)
	);
	
}
