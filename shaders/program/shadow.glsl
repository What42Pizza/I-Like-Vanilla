in_out vec2 texcoord;
#if COLORED_SHADOWS_ENABLED == 1
	in_out vec3 glcolor;
	#if WATER_CAUSTICS_ENABLED == 1
		in_out vec3 playerPos;
		flat in_out uint materialId;
	#endif
#endif



#ifdef FSH

#if COLORED_SHADOWS_ENABLED == 1 && WATER_CAUSTICS_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	vec4 color = texture2D(texture, texcoord);
	
	#if COLORED_SHADOWS_ENABLED == 1
		color.rgb *= glcolor;
	#endif
	
	#if WATER_CAUSTICS_ENABLED == 1
		if (ivec3(color * 255.0 + 0.5) == ivec3(1, 2, 255)) color.rgb -= 0.01;
		if (materialId == BLOCK_ID_WATER) {
			vec3 worldPos = playerPos + cameraPosition;
			worldPos *= 2.5;
			worldPos.y += (worldPos.x + worldPos.z) * 0.5;
			worldPos.y += frameTimeCounter;
			bool noiseLeft = valueNoise(worldPos + vec3(-0.1, 0.0, 0.0)) < 0.5;
			bool noiseRight = valueNoise(worldPos + vec3(0.1, 0.0, 0.0)) < 0.5;
			worldPos.y -= frameTimeCounter;
			bool noiseUp = valueNoise(worldPos + vec3(-0.1, 0.0, 0.0)) < 0.5;
			bool noiseDown = valueNoise(worldPos + vec3(0.1, 0.0, 0.0)) < 0.5;
			bool isBright = noiseLeft != noiseRight || noiseUp != noiseDown;
			color.rgb = mix(ivec3(1, 2, 255) / 255.0, ivec3(1, 3, 255) / 255.0, float(isBright));
		}
	#endif
	
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#if COLORED_LIGHTING_ENABLED == 1
	#include "/lib/colored_lighting/updateVoxelIds.glsl"
#endif
#if WAVING_ENABLED == 1
	#include "/lib/waving.glsl"
#endif

void main() {
	
	// skip entities with this id, currently only used for lightning
	if (entityId == 10000) {
		gl_Position = vec4(1.0);
		return;
	}
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#if COLORED_SHADOWS_ENABLED
		glcolor = gl_Color.rgb;
	#endif
	
	#if !(COLORED_SHADOWS_ENABLED == 1 && WATER_CAUSTICS_ENABLED == 1)
		vec3 playerPos;
	#endif
	playerPos = (shadowModelViewInverse * shadowProjectionInverse * ftransform()).xyz;
	
	uint encodedData = uint(mc_Entity.x + 0.5);
	encodedData *= uint((encodedData & (1u << 14u)) > 0u && encodedData != 65535u);
	#if !(COLORED_SHADOWS_ENABLED == 1 && WATER_CAUSTICS_ENABLED == 1)
		uint materialId;
	#endif
	materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	#if COLORED_LIGHTING_ENABLED == 1
		if (gl_VertexID % 4 == 0) {
			updateVoxelIds(playerPos, materialId);
		}
	#endif
	
	#if EXCLUDE_FOLIAGE == 1
		bool excludeFromShadows = (encodedData & (3u << 12u)) >= (1u << 12u); // test if 'shadow casting' value is 1 or 3
	#else
		bool excludeFromShadows = (encodedData & (3u << 12u)) == (1u << 12u); // test if 'shadow casting' value is 1
	#endif
	if (excludeFromShadows) {
		gl_Position = vec4(1.0);
		return;
	}
	
	#if WAVING_ENABLED == 1
		applyWaving(playerPos.xyz, encodedData);
	#endif
	
	if (materialId == BLOCK_ID_WATER) {
		float horizontalDist = length(playerPos.xz);
		#if PHYSICALLY_WAVING_WATER_ENABLED == 1
			float wavingAmount = PHYSICALLY_WAVING_WATER_AMOUNT_SURFACE;
			#ifdef DISTANT_HORIZONS
				float lengthCylinder = max(horizontalDist, abs(playerPos.y));
				wavingAmount *= smoothstep(far * 0.95 - 10, far * 0.9 - 10, lengthCylinder);
			#endif
			playerPos += cameraPosition;
			playerPos.y += sin(playerPos.x * 0.6 + playerPos.z * 1.4 + frameTimeCounter * 3.0) * 0.015 * wavingAmount;
			playerPos.y += sin(playerPos.x * 0.9 + playerPos.z * 0.6 + frameTimeCounter * 2.5) * 0.01 * wavingAmount;
			playerPos -= cameraPosition;
			playerPos.y -= 0.125 / (1.0 + horizontalDist);
		#endif
		playerPos.y += 0.1 / (1.0 + horizontalDist) * sign(isEyeInWater - 0.5);
		playerPos += mat3(gbufferModelViewInverse) * shadowLightPosition * length(playerPos) / 10000.0;
		#if PIXELATED_SHADOWS == 0
			playerPos.y += 0.0078125 * horizontalDist * float(isEyeInWater == 1); // offset shadow bias
		#else
			playerPos.y += 0.05 + 0.0078125 * horizontalDist * float(isEyeInWater == 1); // offset shadow bias
		#endif
	}
	
	#if WAVING_ENABLED == 1 || PHYSICALLY_WAVING_WATER_ENABLED == 1
		gl_Position = shadowProjection * shadowModelView * vec4(playerPos, 1.0);
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz);
	
}

#endif
