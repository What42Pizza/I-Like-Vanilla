in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec3 glcolor;
in_out vec3 viewPos;
#if FANCY_END_PORTAL_ENABLED == 1
	flat in_out uint materialId;
#endif
#if PBR_TYPE == 0
	flat in_out vec3 normal;
	flat in_out vec2 encodedNormal;
	flat in_out float reflectiveness;
	flat in_out float specularness;
#elif PBR_TYPE == 1
	flat in_out mat3 tbn;
#endif

flat in_out vec3 shadowcasterLight;



#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"

void main() {
	vec2 lmcoord = lmcoord;
	
	
	// get pbr data
	#if PBR_TYPE == 0
		float reflectiveness = reflectiveness;
	#elif PBR_TYPE == 1
		vec2 pbrData = texture2D(specular, texcoord).rg;
		float reflectiveness = pbrData.g;
		float specularness = sqrt(pbrData.r);
		vec3 normal = texture2D(normals, texcoord).rgb;
		normal.xy -= 0.5;
		normal.xy *= PBR_NORMALS_AMOUNT * 0.75;
		normal.xy += 0.5;
		normal = normalize(normal * 2.0 - 1.0);
		normal = tbn * normal;
		vec2 encodedNormal = encodeNormal(normal);
	#endif
	reflectiveness *= mix(BLOCK_REFLECTION_AMOUNT_SURFACE, BLOCK_REFLECTION_AMOUNT_UNDERGROUND, lmcoord.y);
	
	
	// get texture color
	vec4 rawColor = texture2D(MAIN_TEXTURE, texcoord);
	if (rawColor.a < 0.01) discard;
	vec4 color = rawColor;
	color.rgb *= glcolor;
	color.rgb = color.rgb - (4.0 / 27.0) * color.rgb * color.rgb * color.rgb;
	
	float m = getLum(color.rgb);
	m = m * m * (3.0 - 2.0 * m);
	color.rgb *= 1.0 - TEXTURE_CONTRAST * 0.125 + m * TEXTURE_CONTRAST * 0.25;
	
	
	// misc
	
	#if PBR_TYPE == 0
		reflectiveness *= 1.0 - 0.5 * getSaturation(rawColor.rgb);
	#endif
	
	
	#if FANCY_END_PORTAL_ENABLED == 1
		if (materialId == BLOCK_ID_END_PORTAL) {
			
			vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
			vec3 pos = playerPos + cameraPosition;
			vec3 dir = normalize(playerPos);
			float dither = bayer64(gl_FragCoord.xy);
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
			pos += dir * (12.0 + dither);
			float total = 0.0;
			for (int i = 0; i < 8; i++) {
				total *= 0.9;
				float noise = valueNoise(vec4(pos * vec3(1, 0.125, 1), frameTimeCounter * 0.5 + i / 8.0));
				noise = smoothstep(0.45, 0.98, noise);
				total += noise;
				pos -= dir;
			}
			total *= 0.25;
			color.rgb = vec3(pow(total, 1.2), total * total, total);
			color.rgb *= 2.0;
			lmcoord = vec2(0.4, 0.5);
			
		}
	#endif
	
	
	// main lighting
	float _inSunlightAmount;
	doFshLighting(color.rgb, _inSunlightAmount, lmcoord.x, lmcoord.y, specularness, 0.0, viewPos, normal, gl_FragCoord.z);
	
	
	/* DRAWBUFFERS:02 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(1.0, 0.5, 0.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, specularness),
		encodedNormal
	);
	
}

#endif



#ifdef VSH

uniform int blockEntityId;

#include "/utils/projections.glsl"
#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	// get basics
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	#if FANCY_END_PORTAL_ENABLED == 0
		vec3 viewPos;
	#endif
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	
	
	// process gl_Color (foliage tint, vanilla ao)
	vec4 glcolor4 = gl_Color;
	float ao = 1.0 - (1.0 - glcolor4.a) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	glcolor = glcolor4.rgb * ao;
	
	
	// block id stuff
	uint encodedData = uint(max(uint(blockEntityId) - (1u << 12u), 0u) + (1u << 12u));
	#ifndef MODERN_BACKEND
		if (encodedData == 65535u) encodedData = 0u;
	#endif
	#if FANCY_END_PORTAL_ENABLED == 0
		uint materialId;
	#endif
	materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	
	// process normals
	
	vec3 normal = gl_NormalMatrix * gl_Normal;
	
	#if PBR_TYPE == 0
		encodedNormal = encodeNormal(normal);
	#endif
	
	#if PBR_TYPE == 1
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	
	// get block data
	#if PBR_TYPE == 0
		#define GET_REFLECTIVENESS
		#define GET_SPECULARNESS
	#endif
	#define DO_BRIGHTNESS_TWEAKS
	#include "/generated/blockDatas.glsl"
	
	
	gl_Position = viewToNdc(viewPos);
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
	shadowcasterLight = getShadowcasterLight();
	
}

#endif
