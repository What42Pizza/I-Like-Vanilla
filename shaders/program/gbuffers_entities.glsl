in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
#if PBR_TYPE == 0
	flat in_out vec2 encodedNormal;
#elif PBR_TYPE == 1
	flat in_out mat3 tbn;
#endif



#ifdef FSH

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color *= glcolor;
	
	
	// hurt flash, creeper flash, etc
	color.rgb = mix(color.rgb, entityColor.rgb, min(entityColor.a * 1.5, 1.0));
	//color.rgb *= 1.0 + (1.0 - max(lmcoord.x, lmcoord.y)) * entityColor.a;
	
	
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
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color;
	vec3 normal = gl_NormalMatrix * gl_Normal;
	#if PBR_TYPE == 0
		encodedNormal = encodeNormal(normal);
	#endif
	#if PBR_TYPE == 1
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -5.0) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
