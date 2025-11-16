in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec3 glcolor;
flat in_out vec2 normal;
in_out vec3 playerPos;
flat in_out float reflectiveness;
flat in_out float specularness;

#define GLOWING_ORES_ENABLED 1

#if GLOWING_ORES_ENABLED == 1
	varying vec3 glowingColorMin;
	varying vec3 glowingColorMax;
#endif
#if SHOW_DANGEROUS_LIGHT == 1
	flat in_out float isDangerousLight;
#endif



#ifdef FSH

void main() {
	#if GLOWING_ORES_ENABLED == 1 || SHOW_DANGEROUS_LIGHT == 1
		vec2 lmcoord = lmcoord;
	#endif
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if TEMPORAL_FILTER_ENABLED == 1
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
		if (lengthCylinder >= far - 4.0 - 12.0 * dither) discard;
	#else
		float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
		fogDistance *= invFar;
		if (fogDistance >= 0.95) {discard; return;}
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a < 0.01) discard;
	
	#if GLOWING_ORES_ENABLED == 1
		vec3 hsv = rgbToHsv(color.rgb);
		if (all(greaterThan(hsv, glowingColorMin)) && all(lessThan(hsv, glowingColorMax))) {
			lmcoord.x = GLOWING_ORES_STRENGTH + (1.0 - GLOWING_ORES_STRENGTH) * lmcoord.x;
		}
	#endif
	
	float reflectiveness = reflectiveness;
	reflectiveness *= 1.0 - 0.5 * getSaturation(color.rgb);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color.rgb *= glcolor;
	
	
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
	
	playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	
	vec4 glcolor4 = gl_Color;
	glcolor4.rgb = mix(vec3(getLum(glcolor4.rgb)), glcolor4.rgb, FOLIAGE_SATURATION);
	if (glcolor4.rgb != vec3(1.0)) {
		glcolor4.rgb *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE);
		#if SNOWY_TWEAKS_ENABLED == 1
			if (inSnowyBiome > 0.0) {
				float snowyness = (0.9 + 0.1 * wetness) * inSnowyBiome / (1.0 + 0.003 * length(playerPos)) * lmcoord.y * lmcoord.y;
				glcolor4.rgb = mix(glcolor4.rgb, vec3(1.0, 1.02, 1.03), snowyness);
				glcolor4.rgb *= 1.0 + 0.4 * wetness;
				glcolor4.a = mix(glcolor4.a, 1.0, snowyness * 0.5);
			}
		#endif
	}
	float ao = 1.0 - (1.0 - glcolor4.a) * mix(VANILLA_AO_DARK, VANILLA_AO_BRIGHT, max(lmcoord.x, lmcoord.y));
	glcolor = glcolor4.rgb * ao;
	
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	uint materialId = uint(mc_Entity.x);
	uint encodedData = materialId >> 10u;
	// foliage normals
	if ((encodedData & 1u) == 1u && encodedData > 1u) normal = encodeNormal(gl_NormalMatrix * vec3(0.0, 1.0, 0.0));
	
	#define GET_REFLECTIVENESS
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#if GLOWING_ORES_ENABLED == 1
		#define GET_GLOWING_COLOR
	#endif
	#include "/blockDatas.glsl"
	
	#if SHOW_DANGEROUS_LIGHT == 1
		isDangerousLight = 0.0;
		if (gl_Normal.y > 0.9) {
			if (lmcoord.x < 0.5) {
				if (abs(lmcoord.x - 0.05) < 0.02) {
					isDangerousLight = 0.5;
				} else {
					isDangerousLight = 1.0;
				}
			}
		}
	#endif
	
	
	//#define WORLD_TEXTURE_SCALING 2
	//#define TEXTURE_SIZE 16
	//vec2 scale = textureSize(MAIN_TEXTURE, 0) / TEXTURE_SIZE;
	////texcoord *= scale;
	//vec2 texcoordFract = fract(texcoord);
	//vec3 worldPos = playerPos + cameraPosition;
	//vec2 worldTexPos = Project3DPointTo2D(worldPos, vec3(0.0), gl_Normal);
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
	//vec3 worldPos = playerPos + cameraPosition;
	//vec2 worldTexPos = Project3DPointTo2D(worldPos, vec3(0.0), gl_Normal);
	//texcoordFract += mod(worldTexPos, WORLD_TEXTURE_SCALING);
	//texcoordFract /= WORLD_TEXTURE_SCALING;
	//texcoord = floor(texcoord) + texcoordFract;
	//texcoord /= scale;
	
	
	#if WAVING_ENABLED == 1
		applyWaving(playerPos, materialId);
	#endif
	
	
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
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos));
	
}

#endif
