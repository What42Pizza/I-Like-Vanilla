layout(location = 0) out vec4 albedoOut;
layout(location = 1) out vec4 auxDataOut;

#include "/utils/screen_to_view.glsl"
#include "/lib/lighting/vsh_lighting.glsl"



void voxy_emitFragment(VoxyFragmentParameters parameters) {
	
	// basics
	uint materialId = max(parameters.customId - 10000u, 0u);
	
	vec3 screenPos = vec3(gl_FragCoord.xy * pixelSize, gl_FragCoord.z);
	vec3 viewPos = screenToViewVx(screenPos);
	
	
	// lmcoords
	vec2 lmcoord = parameters.lightMap;
	adjustLmcoord(lmcoord);
	
	
	// tint color
	vec3 tintColor = parameters.tinting.rgb;
	if (tintColor != vec3(1.0)) {
		tintColor = mix(vec3(getLum(tintColor)), tintColor, FOLIAGE_SATURATION);
		tintColor *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE);
		#if SNOWY_TWEAKS_ENABLED == 1
			if (inSnowyBiome > 0.0) {
				float snowyness = (0.9 + 0.1 * wetness) * inSnowyBiome / (1.0 + 0.00390625 * length(viewPos)) * lmcoord.y * lmcoord.y;
				tintColor = mix(tintColor, vec3(1.0, 1.02, 1.03), snowyness);
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
	
	uint encodedData = materialId >> 10u;
	// foliage normals
	if ((encodedData & 1u) == 1u && encodedData > 1u) {
		worldNormal = vec3(0.0, 1.0, 0.0);
	}
	
	vec3 normal = mat3(gbufferModelView) * worldNormal;
	
	
	// block-specific datas
	float specularness;
	vec3 glcolor = vec3(1.0);
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/common/blockDatas.glsl"
	
	
	// main color
	vec4 color = parameters.sampledColour;
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.6) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.3);
	color.rgb *= tintColor;
	color.rgb *= glcolor;
	color.rgb *= 0.95 + 0.05 * worldNormal.y;
	
	if (parameters.customId == 11571u) color.rgb *= 0.92; // the voxy lava brightness seems to change every time it's reloaded?
	
	
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
