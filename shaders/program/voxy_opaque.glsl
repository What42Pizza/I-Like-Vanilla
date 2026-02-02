layout(location = 0) out vec4 albedoOut;
layout(location = 1) out vec4 auxDataOut;

#include "/utils/screen_to_view.glsl"
#include "/lib/lighting/vsh_lighting.glsl"



void voxy_emitFragment(VoxyFragmentParameters parameters) {
	
	// basics
	uint encodedData = uint(max(parameters.customId - (1u << 13u), 0) + (1u << 13u));
	uint materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	vec3 screenPos = vec3(gl_FragCoord.xy * pixelSize, gl_FragCoord.z);
	vec3 viewPos = screenToViewVx(screenPos);
	
	
	// lmcoord
	vec2 lmcoord = parameters.lightMap;
	adjustLmcoord(lmcoord);
	
	
	// tint color
	vec3 tintColor = parameters.tinting.rgb;
	if (tintColor != vec3(1.0)) {
		tintColor = mix(vec3(getLum(tintColor)), tintColor, FOLIAGE_SATURATION);
		tintColor *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE);
		#if SNOWY_TWEAKS_ENABLED == 1
			if (inSnowyBiome > 0.0) {
				float snowiness = (0.9 + 0.1 * wetness) * inSnowyBiome / (1.0 + 0.00390625 * length(viewPos)) * lmcoord.y * lmcoord.y;
				tintColor = mix(tintColor, vec3(1.0, 1.02, 1.03), snowiness);
				tintColor *= 1.0 + 0.4 * wetness;
			}
		#endif
	}
	
	
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
	
	
	// block-specific datas
	float specularness;
	vec3 glcolor = vec3(1.0);
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/generated/blockDatas.glsl"
	
	
	// main color
	vec4 color = parameters.sampledColour;
	color.rgb = mix(color.rgb, color.rgb * color.rgb * (3.0 - 2.0 * color.rgb), TEXTURE_CONTRAST * 2.0);
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.08 - TEXTURE_CONTRAST * 0.65);
	color.rgb *= tintColor;
	color.rgb *= glcolor;
	color.rgb *= 0.95 + 0.05 * worldNormal.y;
	
	if (materialId == BLOCK_ID_LAVA) color.rgb *= 0.92; // the voxy lava brightness seems to change every time it's reloaded?
	
	#if LAVA_NOISE_ENABLED == 1
		if (materialId == BLOCK_ID_LAVA) {
			vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
			vec2 worldPos2 = playerPos.xz + cameraPosition.xz + playerPos.y + cameraPosition.y;
			worldPos2 += worldPos2.yx * 0.125;
			float noise = 1.25;
			noise -= valueNoise(vec3(worldPos2 * 0.125, frameTimeCounter * 0.125)) * 0.5;
			worldPos2 += 128.0;
			noise -= valueNoise(vec3(worldPos2 * 0.25 , frameTimeCounter * 0.125)) * 0.25;
			worldPos2 += 128.0;
			noise -= valueNoise(vec3(worldPos2 * 1.0  , frameTimeCounter * 0.125)) * 0.125;
			float upDot = dot(normal, gbufferModelView[1].xyz);
			const float halfStrength = LAVA_NOISE_AMOUNT * 0.5;
			noise = mix(1.0, noise * noise, halfStrength + halfStrength * upDot);
			color.rgb *= noise;
		}
	#endif
	
	
	// vsh lighting
	doVshLighting(lmcoord, viewPos, normal);
	
	
	color.rgb *= 0.5;
	albedoOut = color;
	auxDataOut = vec4(
		pack_2x8(lmcoord),
		pack_2x8(0.0, specularness),
		encodeNormal(normal)
	);
	
}
