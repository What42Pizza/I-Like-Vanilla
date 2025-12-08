in_out vec2 texcoord;
flat in_out vec2 encodedNormal;
in_out vec3 playerPos;
flat in_out float reflectiveness;
flat in_out float specularness;

#if SHOW_DANGEROUS_LIGHT == 1
	flat in_out float isDangerousLight;
#endif



#ifdef FSH

void main() {
	
	vec4 color = texture(gtexture, texcoord);
	vec2 lmcoord;
	float ao;
	vec4 overlayColor;
	clrwl_computeFragment(color, color, lmcoord, ao, overlayColor);
	color.rgb /= ao;
	
	float reflectiveness = reflectiveness;
	reflectiveness *= 1.0 - 0.5 * getSaturation(color.rgb);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	
	color.rgb = mix(color.rgb, overlayColor.rgb, overlayColor.a);
	ao = (ao * ao + ao * 2.0) * 0.3333; // kinda like squaring but not as intense
	ao = 1.0 - (1.0 - ao) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	color.rgb *= ao;
	
	
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

#include "/lib/lighting/vsh_lighting.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	
	vec3 normal = gl_NormalMatrix * gl_Normal;
	encodedNormal = encodeNormal(normal);
	
	uint materialId = uint(max(int(mc_Entity.x) - 10000, 0));
	
	#define GET_REFLECTIVENESS
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/blockDatas.glsl"
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
}

#endif
