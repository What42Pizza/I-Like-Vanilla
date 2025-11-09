#ifndef INCLUDE_REPROJECTION
#define INCLUDE_REPROJECTION



#if ISOMETRIC_RENDERING_ENABLED == 0
	
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset) {
		screenPos = screenPos * 2.0 - 1.0;
		vec4 viewPos = gbufferProjectionInverse * vec4(screenPos, 1.0);
		vec3 playerPos = mat3(gbufferModelViewInverse) * (viewPos.xyz / viewPos.w);
		
		vec3 prevPlayerPos = playerPos + cameraOffset;
		vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevPlayerPos;
		vec4 prevCoord = gbufferPreviousProjection * vec4(prevViewPos, 1.0);
		return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
	}
	
#else
	
	#include "/lib/isometric.glsl"
	
	vec2 reprojection(vec3 screenPos, vec3 cameraOffset) {
		
		vec3 playerPos = screenPos * 2.0 - 1.0;
		playerPos.z += getIsometricOffset();
		playerPos /= getIsometricScale();
		playerPos = mat3(gbufferModelViewInverse) * playerPos;
		
		vec3 prevPlayerPos = playerPos + cameraOffset;
		
		vec2 prevCoord = (mat3(gbufferPreviousModelView) * prevPlayerPos).xy;
		prevCoord.xy *= getIsometricScale().xy;
		return prevCoord.xy * 0.5 + 0.5;
	}
	
#endif



#endif
