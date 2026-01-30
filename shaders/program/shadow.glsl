in_out vec2 texcoord;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord);
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
	
	if (entityId == 10000) {
		gl_Position = vec4(1.0);
		return;
	}
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec3 playerPos = (shadowModelViewInverse * shadowProjectionInverse * ftransform()).xyz;
	
	uint encodedData = uint(max(mc_Entity.x - (1u << 13u), 0) + (1u << 13u));
	uint materialId = encodedData;
	materialId &= (1u << 10u) - 1u;
	
	#if COLORED_LIGHTING_ENABLED == 1
		if (gl_VertexID % 4 == 0) {
			updateVoxelIds(playerPos, materialId);
		}
	#endif
	
	#if EXCLUDE_FOLIAGE == 1
		bool excludeFromShadows = (encodedData & (1u << 15u)) == (1u << 15u); // test if 'shadow casting' value is 1 or 3
	#else
		bool excludeFromShadows = (encodedData & (3u << 14u)) == (1u << 14u); // test if 'shadow casting' value is 1
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
		#if PIXELATED_SHADOWS == 0
			playerPos.y += 0.0078125 * horizontalDist * uint(isEyeInWater == 1); // offset shadow bias
		#else
			playerPos.y += 0.05 + 0.0078125 * horizontalDist * uint(isEyeInWater == 1); // offset shadow bias
		#endif
	}
	
	#if WAVING_ENABLED == 1 || PHYSICALLY_WAVING_WATER_ENABLED == 1 || COLORED_LIGHTING_ENABLED == 1
		gl_Position = shadowProjection * shadowModelView * vec4(playerPos, 1.0);
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz);
	
}

#endif
