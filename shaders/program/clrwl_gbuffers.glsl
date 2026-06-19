in_out vec2 texcoord;
in_out vec3 glcolor;
flat in_out vec3 worldNormal;
flat in_out vec3 normal;
flat in_out vec2 encodedNormal;
in_out vec3 viewPos;
flat in_out float reflectiveness;
flat in_out float specularness;

#if SHOW_DANGEROUS_LIGHT == 1
	in_out vec3 playerPos;
	flat in_out float isDangerousLight;
#endif



#ifdef FSH

#include "/lib/lighting/vsh_lighting.glsl"

void main() {
	
	vec4 color = texture2D(gtexture, texcoord);
	vec2 lmcoord;
	float ao;
	vec4 overlayColor;
	clrwl_computeFragment(color, color, lmcoord, ao, overlayColor);
	color.rgb /= ao;
	adjustLmcoord(lmcoord);
	
	vec3 glcolor = glcolor;
	doVshLighting(lmcoord, glcolor, viewPos, normal, worldNormal);
	
	float reflectiveness = reflectiveness;
	reflectiveness *= 1.0 - 0.5 * getSaturation(color.rgb);
	
	color.rgb = color.rgb - (4.0 / 27.0) * color.rgb * color.rgb * color.rgb;
	color.rgb = mix(color.rgb, overlayColor.rgb, overlayColor.a);
	ao = 1.0 - (1.0 - ao) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	color.rgb *= ao;
	color.rgb *= glcolor;
	
	float m = getLum(color.rgb);
	m = m * m * (3.0 - 2.0 * m);
	color.rgb *= 1.0 - TEXTURE_CONTRAST * 0.125 + m * TEXTURE_CONTRAST * 0.25;
	color.rgb = color.rgb * (1.0 + TEXTURE_CONTRAST_2 * 0.025) - TEXTURE_CONTRAST_2 * 0.025;
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		if (isDangerousLight > 0.0) {
			vec3 blockPos = fract(playerPos + cameraPosition);
			float centerDist = length(blockPos.xz - 0.5);
			vec3 indicatorColor = isDangerousLight > 0.75 ? vec3(1.0, 0.0, 0.0) : vec3(1.0, 1.0, 0.0);
			color.rgb = mix(color.rgb, indicatorColor, 0.35 * float(centerDist < 0.45));
			lmcoord.x = max(lmcoord.x, 0.1 * float(centerDist < 0.45));
		}
	#endif
	
	
	/* DRAWBUFFERS:02 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(1.0, 0.75, 0.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_7_7_1_1(reflectiveness, specularness, 0.0, 1.0),
		encodedNormal
	);
	
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"

#if TAA_ENABLED == 1 && TEMPORAL_FILTER_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = vec3(1.0);
	
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	#if SHOW_DANGEROUS_LIGHT == 0
		vec3 playerPos;
	#endif
	playerPos = transform(gbufferModelViewInverse, viewPos);
	
	worldNormal = gl_Normal;
	normal = gl_NormalMatrix * gl_Normal;
	encodedNormal = encodeNormal(normal);
	
	uint encodedData = uint(mc_Entity.x + 0.5);
	encodedData *= uint((encodedData & (1u << 14u)) > 0u && encodedData != 65535u);
	uint materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	#define GET_REFLECTIVENESS
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/generated/blockDatas.glsl"
	
	
	gl_Position = viewToNdc(viewPos);
	
	
	#if TAA_ENABLED == 1 && TEMPORAL_FILTER_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
}

#endif
