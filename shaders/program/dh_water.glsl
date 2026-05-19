#undef SHADOWS_ENABLED
#undef HANDHELD_LIGHT_ENABLED
#define HANDHELD_LIGHT_ENABLED 0

in_out vec4 glcolor;
in_out vec2 lmcoord;
in_out vec3 viewPos;
in_out vec3 playerPos;
flat in_out vec3 normal;
flat in_out int dhBlock;

#if BORDER_FOG_ENABLED == 1
	in_out float fogAmount;
#endif



#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"

#include "/utils/projections.glsl"
#if WAVING_WATER_SURFACE_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	float dither = bayer64(gl_FragCoord.xy);
	#if TEMPORAL_FILTER_ENABLED == 1
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	if (lengthCylinder < far - 8.0 - 8.0 * dither) discard;
	
	float vanillaDepth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 vanillaViewPos = screenToView(vec3(texelcoord * pixelSize, vanillaDepth));
	if (vanillaViewPos.z > viewPos.z && vanillaDepth < 1.0) discard;
	
	
	vec4 color = glcolor;
	
	
	// add noise for fake texture
	float worldScale = 300.0 / length(playerPos);
	uvec3 noisePos = uvec3(ivec3((playerPos + cameraPosition) * ceil(worldScale) + 0.5));
	randomizeUint(noisePos.x);
	randomizeUint(noisePos.y);
	randomizeUint(noisePos.z);
	uint noise = noisePos.x ^ noisePos.y ^ noisePos.z;
	color.rgb += 0.03 * randomFloat(noise);
	//color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));
	
	
	float reflectiveness = clamp(0.5 + 3.0 * (getLum(color.rgb) * 1.5 - 0.5), 0.0, 1.0);
	
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	if (dhBlock == DH_BLOCK_WATER) {
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, WATER_BIOME_INFLUENCE);
		
		vec3 viewDir = normalize(viewPos);
		float fresnel = -dot(normal, viewDir);
		
		
		#if WAVING_WATER_SURFACE_ENABLED == 1
			vec2 noisePos = (playerPos.xz + cameraPosition.xz) / WAVING_WATER_SCALE * 0.25;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.125;
			vec2 rawNormalNoise;
			if (wavingSurfaceAmount > 0.00001) {
				float fresnelMult = mix(WAVING_WATER_FRESNEL_UNDERGROUND * 0.55, WAVING_WATER_FRESNEL_SURFACE * 0.55, lmcoord.y);
				float frameTimeCounter = frameTimeCounter * WAVING_WATER_SPEED;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				normal = vec3(0.0, 1.0, 0.0);
				normal.xz += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4;
				normal.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25;
				//normal.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25;
				rawNormalNoise = normal.xz;
				vec3 normalWithoutMult = mat3(gbufferModelView) * normalize(normal);
				normal.xz *= wavingSurfaceAmount;
				normal = mat3(gbufferModelView) * normalize(normal);
				fresnel = -dot(normalWithoutMult, viewDir);
				color.rgb *= 1.0 + (0.5 - fresnel) * fresnelMult;
			}
		#endif
		
		
		float opaqueDepth = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		vec3 opaqueViewPos = screenToViewDh(vec3(texelcoord * pixelSize, opaqueDepth));
		float blockDepth = length(viewPos);
		float opaqueBlockDepth = length(opaqueViewPos);
		#if BORDER_FOG_ENABLED == 1
			// this tries to fix underwater border fog but it breaks more stuff than it fixes
			//vec3 opaquePlayerPos = mat3(gbufferModelViewInverse) * opaqueViewPos;
			//opaqueBlockDepth = mix(opaqueBlockDepth, far, getBorderFogAmount(opaquePlayerPos));
		#endif
		float waterDepth = opaqueBlockDepth - blockDepth;
		float waterDepthPercent = exp(waterDepth / -16.0); // note: 0.0 is deep and 1.0 is shallow
		if (isEyeInWater == 1) {
			color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
		} else {
			color.a = 1.0 - mix(WATER_TRANSPARENCY_DEEP, WATER_TRANSPARENCY_SHALLOW, waterDepthPercent);
		}
		color.a *= 1.0 - fresnel * 0.125;
		
		color.rgb *= mix(WATER_TINT_DEEP, WATER_TINT_SHALLOW, waterDepthPercent);
		
		//#if WATER_FOAM_ENABLED == 1
		//	float foamAmount = percentThrough(waterDepth, 1.2, 0.0);
		//	reflectiveness *= 1.0 - foamAmount;
		//	foamAmount *= foamAmount;
		//	foamAmount *= 1.0 - 0.25 * fresnel;
		//	foamAmount *= 0.5 + 0.5 * lmcoord.y;
		//	#if WAVING_WATER_SURFACE_ENABLED == 1
		//		foamAmount *= 0.35 + 0.65 * length(rawNormalNoise);
		//	#endif
		//	color.rgb = mix(color.rgb, vec3(0.75 + 0.25 * dayPercent), foamAmount * WATER_FOAM_AMOUNT * 2.5);
		//#endif
		
		//// water needs to be more opaque in dark areas
		//float alphaLift = max(lmcoord.x, lmcoord.y * dayPercent);
		//alphaLift = sqrt(alphaLift);
		//alphaLift = (1.0 - alphaLift) * (1.2 - screenBrightness);
		//#if WATER_FOAM_ENABLED == 1
		//	alphaLift += foamAmount * WATER_FOAM_AMOUNT;
		//#endif
		//color.a = 1.0 - (1.0 - alphaLift) * (1.0 - color.a);
		
	}
	
	
	float specularness = 0.3;
	if (dhBlock == DH_BLOCK_WATER) {
		reflectiveness = mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y) * max(color.a * 1.3, 1.0);
		specularness = 2.0;
	}
	
	
	// main lighting
	float _inSunlightAmount;
	doFshLighting(color.rgb, _inSunlightAmount, lmcoord.x, lmcoord.y, specularness, 0.0, viewPos, normal, gl_FragCoord.z);
	
	
	// fog
	#if BORDER_FOG_ENABLED == 1
		color.a *= 1.0 - fogAmount;
	#endif
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, 0.0),
		encodeNormal(normal)
	);
	
}

#endif





#ifdef VSH

#define PROJECTION_MATRIX gl_ProjectionMatrix
#include "/utils/projections.glsl"
#include "/lib/lighting/vsh_lighting.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/utils/borderFogAmount.glsl"
#endif

void main() {
	glcolor = gl_Color;
	glcolor.rgb *= 0.95;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	normal = gl_NormalMatrix * gl_Normal;
	dhBlock = dhMaterialId;
	
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	if (dhBlock == DH_BLOCK_WATER) {
		playerPos.y -= 2.0 / 16.0;
		viewPos = mat3(gbufferModelView) * playerPos;
	}
	
	
	gl_Position = viewToNdc(viewPos);
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	#if BORDER_FOG_ENABLED == 1
		float _fogDistance;
		fogAmount = getBorderFogAmount(playerPos, _fogDistance);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
