#if SHADOWS_ON_TRANSPARENTS == 0
	#undef SHADOWS_ENABLED
	#define SHADOWS_ENABLED 0
#endif

in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec3 glcolor;
in_out vec3 viewPos;
in_out vec3 playerPos;
flat in_out vec3 normal;
flat in_out uint materialId;
flat in_out float reflectiveness;
flat in_out float specularness;

flat in_out vec2 midTexCoord;
flat in_out vec2 midCoordOffset;

flat in_out vec3 shadowcasterLight;

#if WAVING_WATER_SURFACE_ENABLED == 1 || FANCY_NETHER_PORTAL_ENABLED == 1
	in_out mat3 tbn;
#endif
#if BORDER_FOG_ENABLED == 1
	in_out float fogAmount;
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
			dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		#endif
		float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y)) * 0.99;
		if (lengthCylinder >= far - 10 - 8 * dither) discard;
	#else
		float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
		fogDistance *= invFar;
		if (fogDistance >= 0.95) {discard; return;}
	#endif
	
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	float reflectiveness = reflectiveness;
	reflectiveness *= 1.0 - 0.5 * getSaturation(color.rgb);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color.rgb *= glcolor;
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	
	if (materialId == 1570u) {
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 0.8);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		vec3 viewDir = normalize(viewPos);
		float fresnel = -dot(normal, viewDir);
		
		
		#if WAVING_WATER_SURFACE_ENABLED == 1
			vec2 noisePos = (playerPos.xz + cameraPosition.xz) / WAVING_WATER_SCALE * 0.25;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.125;
			if (wavingSurfaceAmount > 0.00001) {
				float fresnelMult = mix(WAVING_WATER_FRESNEL_UNDERGROUND * 0.55, WAVING_WATER_FRESNEL_SURFACE * 0.55, lmcoord.y);
				float frameTimeCounter = frameTimeCounter * WAVING_WATER_SPEED;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				normal = vec3(0.0, 0.0, 1.0);
				normal.xy += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4;
				normal.xy += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25;
				normal.xy += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25;
				vec3 normalWithoutMult = tbn * normalize(normal);
				normal.xy *= wavingSurfaceAmount;
				normal = tbn * normalize(normal);
				fresnel = dot(normalWithoutMult, viewDir); // note: there should be made negative, but instead the next line does 1+fresnel instead of 1-fresnel
				color.rgb *= 1.0 + (fresnel + 0.5) * fresnelMult;
			}
		#endif
		
		
		#if WATER_DEPTH_BASED_TRANSPARENCY == 1
			if (isEyeInWater == 1) {
				color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
			} else {
				float blockDepth = toBlockDepth(gl_FragCoord.z);
				float opaqueBlockDepth = toBlockDepth(texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r);
				float waterDepth = opaqueBlockDepth - blockDepth;
				color.a = 1.0 - mix(WATER_TRANSPARENCY_DEEP, WATER_TRANSPARENCY_SHALLOW, 4.0 / (4.0 + waterDepth));
			}
		#else
			color.a = 1.0 - (WATER_TRANSPARENCY_DEEP + WATER_TRANSPARENCY_SHALLOW) / 2.0;
		#endif
		color.a *= 1.0 + fresnel * 0.125;
		//color.rgb = vec3(-fresnel);
		
	}
	
	
	// nether portal
	#if FANCY_NETHER_PORTAL_ENABLED == 1
		if (materialId == 1910u) {
			vec3 tangentViewDir = normalize(transpose(tbn) * viewPos);
			tangentViewDir.x *= -1.0;
			
			vec2 texcoordInt = texcoord * atlasSize;
			vec2 distToNext = fract(texcoordInt);
			
			distToNext = mix(1.0 - distToNext, distToNext, step(0.0, tangentViewDir.xy)); // invert distToNext depending on direction of tangentViewDir
			distToNext /= abs(tangentViewDir.xy);
			
			tangentViewDir *= min(distToNext.x, distToNext.y);
			float dist = length(tangentViewDir);
			
			ivec2 neighborCoord = ivec2(texcoordInt);
			neighborCoord -= distToNext.x < distToNext.y ? ivec2(sign(tangentViewDir.x), 0) : ivec2(0, sign(tangentViewDir.y)); // I'm not entirely sure why it's -= instead of +=, must be coord space shenanigans
			
			ivec2 minCoord = ivec2((midTexCoord - midCoordOffset) * atlasSize);
			ivec2 maxCoord = ivec2((midTexCoord + midCoordOffset) * atlasSize + 1.0);
			neighborCoord -= minCoord;
			neighborCoord %= maxCoord - minCoord;
			neighborCoord += minCoord;
			
			vec4 neighborPixel = texelFetch(MAIN_TEXTURE, neighborCoord, 0);
			neighborPixel /= 1.0 + dist * 0.1;
			color = max(color, neighborPixel * 0.9);
			
		}
	#endif
	
	
	// main lighting
	doFshLighting(color.rgb, lmcoord.x, lmcoord.y, specularness, viewPos, normal);
	
	
	// fog
	#if BORDER_FOG_ENABLED == 1
		color.a *= 1.0 - fogAmount;
	#endif
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, 0.0),
		encodeNormal(normal)
	);
	
}

#endif



#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
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
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	normal = gl_NormalMatrix * gl_Normal;
	
	materialId = uint(max(int(mc_Entity.x) - 10000, 0));
	#define GET_REFLECTIVENESS
	#define GET_SPECULARNESS
	#define DO_BRIGHTNESS_TWEAKS
	#include "/blockDatas.glsl"
	
	midTexCoord = mat2(gl_TextureMatrix[0]) * mc_midTexCoord;
	midCoordOffset = abs(texcoord - midTexCoord);
	
	shadowcasterLight = getShadowcasterLight();
	
	
	#if WAVING_WATER_SURFACE_ENABLED == 1 || FANCY_NETHER_PORTAL_ENABLED == 1
		vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vec3 bitangent = normalize(cross(normal, tangent) * at_tangent.w);
		tbn = mat3(tangent, bitangent, normal);
	#endif
	
	
	#if PHYSICALLY_WAVING_WATER_ENABLED == 1
		if (materialId == 1570u) {
			float wavingAmount = mix(PHYSICALLY_WAVING_WATER_AMOUNT_UNDERGROUND, PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE, lmcoord.y);
			#ifdef DISTANT_HORIZONS
				float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			playerPos += cameraPosition;
			playerPos.y += sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.015 * wavingAmount;
			playerPos.y += sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.01 * wavingAmount;
			playerPos -= cameraPosition;
		}
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.5) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	#if BORDER_FOG_ENABLED == 1
		fogAmount = getBorderFogAmount(playerPos);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
