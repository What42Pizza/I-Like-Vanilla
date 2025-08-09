#if SHADOWS_ON_TRANSPARENTS == 0
	#undef SHADOWS_ENABLED
	#define SHADOWS_ENABLED 0
#endif

#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec3 glcolor;
	in_out vec3 viewPos;
	in_out vec3 playerPos;
	flat in_out vec3 normal;
	flat in_out int materialId;
	
	flat in_out vec3 shadowcasterColor;
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		in_out mat3 tbn;
	#endif
	#if BORDER_FOG_ENABLED == 1
		in_out float fogAmount;
	#endif
	
#endif





#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"

#if WAVING_WATER_SURFACE_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	#ifdef DISTANT_HORIZONS
		float dither = bayer64(gl_FragCoord.xy);
		#if TEMPORAL_FILTER_ENABLED == 1
			#include "/import/frameCounter.glsl"
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y)) * 0.99;
		#include "/import/far.glsl"
		if (lengthCylinder >= far - 10 - 8 * dither) discard;
	#else
		float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
		#include "/import/invFar.glsl"
		fogDistance *= invFar;
		if (fogDistance >= 0.95) {discard; return;}
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	float reflectiveness = getLum(color.rgb) * 1.5;
	reflectiveness = clamp(0.5 + (reflectiveness - 0.5) * 3.0, 0.0, 1.0);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.5);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color.rgb *= glcolor;
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (materialId == 9000) {
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 0.8);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		
		// waving water normals
		#if WAVING_WATER_SURFACE_ENABLED == 1
			float fresnel = -dot(normal, normalize(viewPos));
			#include "/import/cameraPosition.glsl"
			#include "/import/frameTimeCounter.glsl"
			vec3 noisePos = vec3(playerPos.xz + cameraPosition.xz, frameTimeCounter * WAVING_WATER_SPEED);
			noisePos.xy /= WAVING_WATER_SCALE * 2.0;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.02;
			float height = 1.0 - abs(simplexNoise(noisePos));
			float heightX = 1.0 - abs(simplexNoise(noisePos + vec3(0.01, 0.0, 0.0)));
			float heightZ = 1.0 - abs(simplexNoise(noisePos + vec3(0.0, 0.01, 0.0)));
			vec3 dirX = vec3(0.01, (height - heightX) * wavingSurfaceAmount, 0.0);
			vec3 dirZ = vec3(0.0, (height - heightZ) * wavingSurfaceAmount, 0.01);
			normal = cross(dirZ, dirX);
			normal = normalize(normal);
			normal = tbn * vec3(-normal.x, normal.z, normal.y); // y = up -> z = up & tangent -> world
			float newFresnel = dot(normal, normalize(viewPos)); // should be inverted but it would be inverted again in the next step anyways
			color.rgb *= clamp(1.0 + WAVING_WATER_FRESNEL_MULT / wavingSurfaceAmount * 0.07 * (fresnel + newFresnel), 0.0, 1.5); // basically `color *= 1+(fresnel-newFresnel)` but it's weird because of settings and wavingSurfaceAmount
		#endif
		
		
		#if WATER_DEPTH_BASED_TRANSPARENCY == 1
			#include "/import/isEyeInWater.glsl"
			if (isEyeInWater == 1) {
				color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
			} else {
				float blockDepth = toBlockDepth(gl_FragCoord.z  ARGS_IN);
				float opaqueBlockDepth = toBlockDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r  ARGS_IN);
				float waterDepth = opaqueBlockDepth - blockDepth;
				color.a = 1.0 - mix(WATER_TRANSPARENCY_DEEP, WATER_TRANSPARENCY_SHALLOW, 4.0 / (4.0 + waterDepth));
			}
		#else
			color.a = 1.0 - (WATER_TRANSPARENCY_DEEP + WATER_TRANSPARENCY_SHALLOW) / 2.0;
		#endif
		
	}
	
	
	if (materialId == 9000) {
		reflectiveness *= mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y) * max(color.a * 1.3, 1.0);
	} else {
		reflectiveness *= ((materialId % 1000 - materialId % 100) / 100) * 0.15;
	}
	float specular_amount = ((materialId % 10000 - materialId % 1000) / 1000) * 0.11;
	
	
	// main lighting
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, specular_amount, viewPos, normal  ARGS_IN);
	
	
	// fog
	#if BORDER_FOG_ENABLED == 1
		color.a *= 1.0 - fogAmount;
	#endif
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(encodeNormal(normal)),
		packVec2(reflectiveness * 0.5, 0.0),
		1.0
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterColor.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/borderFogAmount.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color.rgb;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * vec4(viewPos, 1.0));
	normal = gl_NormalMatrix * gl_Normal;
	
	#include "/import/mc_Entity.glsl"
	materialId = int(mc_Entity.x);
	if (materialId < 1000) materialId = 0;
	materialId %= 100000;
	
	shadowcasterColor = getShadowcasterColor(ARG_IN);
	
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		#include "/import/at_tangent.glsl"
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	
	#if PHYSICALLY_WAVING_WATER_ENABLED == 1
		if (materialId == 9000) {
			float wavingAmount = mix(PHYSICALLY_WAVING_WATER_AMOUNT_UNDERGROUND, PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE, lmcoord.y);
			#ifdef DISTANT_HORIZONS
				float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
				#include "/import/far.glsl"
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			#include "/import/cameraPosition.glsl"
			playerPos += cameraPosition;
			#include "/import/frameTimeCounter.glsl"
			playerPos.y += (sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.5 - 0.5) * 0.03 * wavingAmount;
			playerPos.y += (sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.5 - 0.5) * 0.02 * wavingAmount;
			playerPos -= cameraPosition;
		}
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		#include "/import/gbufferModelView.glsl"
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	#if BORDER_FOG_ENABLED == 1
		fogAmount = getBorderFogAmount(playerPos  ARGS_IN);
	#endif
	
	
	#if USE_SIMPLE_LIGHT == 1
		if (glcolor.r == glcolor.g && glcolor.g == glcolor.b) {
			glcolor = vec3(1.0);
		}
	#endif
	
	
	doVshLighting(length(playerPos)  ARGS_IN);
	
}

#endif
