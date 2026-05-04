in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
#if PBR_TYPE == 0
	flat in_out vec3 normal;
#elif PBR_TYPE == 1
	flat in_out mat3 tbn;
#endif
in_out float blockDepth;

#if MIXED_PARTICLE_RENDERING == 0
	in_out vec3 viewPos;
	flat in_out vec3 shadowcasterLight;
#endif



#ifdef FSH

#if MIXED_PARTICLE_RENDERING == 0
	#include "/lib/lighting/simple_fsh_lighting.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	
	
	// hide nearby particles
	float transparency = percentThrough(blockDepth, 0.5, 1.2);
	color.a *= (transparency - 1.0) * NEARBY_PARTICLE_TRANSPARENCY + 1.0;
	color.a *= 1.0 - COLORED_PARTICLE_TRANSPARENCY * getSaturation(glcolor.rgb);
	
	
	#if PBR_TYPE == 0
		float reflectiveness = 0.0;
		float specularness = 0.3;
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
	
	
	#if MIXED_PARTICLE_RENDERING == 0
		doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, specularness, viewPos, normal);
	#endif
	
	
	/* DRAWBUFFERS:03 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.5, 0.75, 0.75, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, 0.0),
		encodeNormal(normal)
	);
	
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"
#include "/lib/lighting/vsh_lighting.glsl"
#if MIXED_PARTICLE_RENDERING == 0
	#include "/utils/getShadowcasterLight.glsl"
#endif

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	lmcoord = min(lmcoord + 0.05, 1.0);
	glcolor = gl_Color;
	glcolor.rgb *= 1.25;
	glcolor.a = sqrt(glcolor.a);
	#if PBR_TYPE != 0
		vec3 normal;
	#endif
	normal = gl_NormalMatrix * gl_Normal;
	#if PBR_TYPE == 1
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	#if MIXED_PARTICLE_RENDERING == 1
		vec3 viewPos;
	#endif
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	blockDepth = length(viewPos);
	
	
	gl_Position = viewToNdc(viewPos);
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
	#if MIXED_PARTICLE_RENDERING == 0
		shadowcasterLight = getShadowcasterLight();
	#endif
	
}

#endif
