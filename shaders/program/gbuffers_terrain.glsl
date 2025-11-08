#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec3 glcolor;
	flat in_out vec2 normal;
	flat in_out int materialId;
	in_out vec3 playerPos;
	in_out float specularMult;
	
	#if SHOW_DANGEROUS_LIGHT == 1
		in_out float isDangerousLight;
	#endif
	
#endif





#ifdef FSH

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if TEMPORAL_FILTER_ENABLED == 1
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 4.0 - 12.0 * dither) discard;
	#else
		float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
		#include "/import/invFar.glsl"
		fogDistance *= invFar;
		if (fogDistance >= 0.95) {discard; return;}
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a < 0.01) discard;
	float reflectiveness = getLum(color.rgb) * 1.5;
	reflectiveness = clamp(0.5 + (reflectiveness - 0.5) * 3.0, 0.0, 1.0);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color.rgb *= glcolor;
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		#include "/import/cameraPosition.glsl"
		vec3 blockPos = fract(playerPos + cameraPosition);
		float centerDist = length(blockPos - 0.5);
		color.rgb = mix(color.rgb, vec3(1.0, 0.0, 0.0), isDangerousLight * 0.35 * float(centerDist < 0.65));
	#endif
	
	
	reflectiveness *= ((materialId % 1000 - materialId % 100) / 100) * 0.15 * mix(BLOCK_REFLECTION_AMOUNT_UNDERGROUND, BLOCK_REFLECTION_AMOUNT_SURFACE, lmcoord.y);
	float specular_amount = ((materialId % 10000 - materialId % 1000) / 1000) * 0.11 * specularMult;
	
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness * 0.5, specular_amount),
		normal
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif
#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

//vec2 Project3DPointTo2D(vec3 point, vec3 planeOrigin, vec3 planeNormal  ARGS_OUT) {
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
	glcolor = mix(vec3(getLum(gl_Color.rgb)), gl_Color.rgb, FOLIAGE_SATURATION);
	if (glcolor != vec3(1.0)) glcolor *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE);
	glcolor *= 1.0 - (1.0 - gl_Color.a) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	materialId %= 100000;
	
	if ((materialId % 100) - (materialId % 10) == 10) {
		normal = encodeNormal(gl_NormalMatrix * vec3(0.0, 1.0, 0.0));
		specularMult = 0.25;
	} else {
		specularMult = 1.0;
	}
	
	
	#if SHOW_DANGEROUS_LIGHT == 1
		isDangerousLight = float(gl_Normal.y > 0.9 && lmcoord.x < 0.5);
	#endif
	
	
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	
	
	//#define WORLD_TEXTURE_SCALING 2
	//#define TEXTURE_SIZE 16
	//vec2 scale = textureSize(MAIN_TEXTURE, 0) / TEXTURE_SIZE;
	////texcoord *= scale;
	//vec2 texcoordFract = fract(texcoord);
	//#include "/import/cameraPosition.glsl"
	//vec3 worldPos = playerPos + cameraPosition;
	//vec2 worldTexPos = Project3DPointTo2D(worldPos, vec3(0.0), gl_Normal  ARGS_IN);
	//texcoordFract += mod(worldTexPos, WORLD_TEXTURE_SCALING);
	//texcoordFract /= WORLD_TEXTURE_SCALING;
	////texcoord = floor(texcoord) + texcoordFract;
	////texcoord /= scale;
	
	
	// fun way to screw up the textures:
	//#define WORLD_TEXTURE_SCALING 2
	//#define TEXTURE_SIZE 16
	//vec2 scale = textureSize(MAIN_TEXTURE, 0) / TEXTURE_SIZE;
	//texcoord *= scale;
	//vec2 texcoordFract = fract(texcoord);
	//#include "/import/cameraPosition.glsl"
	//vec3 worldPos = playerPos + cameraPosition;
	//vec2 worldTexPos = Project3DPointTo2D(worldPos, vec3(0.0), gl_Normal  ARGS_IN);
	//texcoordFract += mod(worldTexPos, WORLD_TEXTURE_SCALING);
	//texcoordFract /= WORLD_TEXTURE_SCALING;
	//texcoord = floor(texcoord) + texcoordFract;
	//texcoord /= scale;
	
	
	#if WAVING_ENABLED == 1
		applyWaving(playerPos  ARGS_IN);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
