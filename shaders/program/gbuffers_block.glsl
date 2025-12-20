in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec3 glcolor;
flat in_out vec2 encodedNormal;
in_out vec3 playerPos;
#if PBR_TYPE == 0
	flat in_out float reflectiveness;
	flat in_out float specularness;
#elif PBR_TYPE == 1
	flat in_out mat3 tbn;
#endif



#ifdef FSH

void main() {
	vec2 lmcoord = lmcoord;
	
	
	#if PBR_TYPE == 0
		float reflectiveness = reflectiveness;
	#elif PBR_TYPE == 1
		float reflectiveness = 0.0;
		float specularness = 0.0;
		vec3 normal = texture2D(normals, texcoord).rgb;
        normal.xy -= 0.5;
		normal.xy *= PBR_NORMALS_AMOUNT;
        normal.xy += 0.5;
		normal = normalize(normal * 2.0 - 1.0);
		normal = tbn * normal;
		vec2 encodedNormal = encodeNormal(normal);
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a < 0.01) discard;
	
	
	#if PBR_TYPE == 0
		reflectiveness *= 1.0 - 0.5 * getSaturation(color.rgb);
	#endif
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color.rgb *= glcolor;
	
	
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

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

//vec2 Project3DPointTo2D(vec3 point, vec3 planeOrigin, vec3 planeNormal) {
//	// Step 1: Project the point onto the plane
//	vec3 toPoint = point - planeOrigin;
//	vec3 normal = normalize(planeNormal);
//	vec3 projected = point - dot(toPoint, normal) * normal;

//	// Step 2: Create 2D basis vectors (u and v) on the plane
//	vec3 x = cross(normal, vec3(0.0, 1.0, 0.0));
//	if (dot(x, x) < 0.001) x = cross(normal, vec3(1.0, 0.0, 0.0));
//	x = normalize(x);
//	vec3 y = cross(normal, x);

//	// Step 3: Get 2D coordinates
//	vec3 relative = projected - planeOrigin;
//	return vec2(dot(relative, x), dot(relative, y));
//}

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	
	vec4 glcolor4 = gl_Color;
	#if SHADOWS_ENABLED == 1
		glcolor4.a = (glcolor4.a * glcolor4.a + glcolor4.a * 2.0) * 0.3333; // kinda like squaring but not as intense
	#else
		glcolor4.a = (glcolor4.a * glcolor4.a + glcolor4.a) * 0.5; // kinda like squaring but not as intense
	#endif
	float ao = 1.0 - (1.0 - glcolor4.a) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	lmcoord.x *= 0.95;
	glcolor = glcolor4.rgb * ao;
	
	uint materialId = uint(max(int(mc_Entity.x) - 10000, 0));
	
	vec3 normal = gl_NormalMatrix * gl_Normal;
	
	#if PBR_TYPE == 0
		encodedNormal = encodeNormal(normal);
	#endif
	
	#if PBR_TYPE == 1
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	
	#if PBR_TYPE == 0
		#define GET_REFLECTIVENESS
		#define GET_SPECULARNESS
	#endif
	#define DO_BRIGHTNESS_TWEAKS
	#include "/blockDatas.glsl"
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * startMat(viewPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
