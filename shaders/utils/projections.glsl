#ifndef INCLUDE_PROJECTION
#define INCLUDE_PROJECTION

#ifndef PROJECTION_MATRIX
	#define PROJECTION_MATRIX gbufferProjection
#endif
#ifndef INVERSE_PROJECTION_MATRIX
	#define INVERSE_PROJECTION_MATRIX gbufferProjectionInverse
#endif



#if PROJECTION_TYPE == 0
	
	
	
	vec4 viewToNdc(vec3 viewPos) {
		return PROJECTION_MATRIX * vec4(viewPos, 1.0);
	}
	
	// CODE FROM COMPLEMENTARY REIMAGINED:
	vec3 screenToView(vec3 screenPos) {
		vec3 ndcPos = screenPos * 2.0 - 1.0;
		vec4 iProjDiag = vec4(
			gbufferProjectionInverse[0].x,
			gbufferProjectionInverse[1].y,
			gbufferProjectionInverse[2].zw
		);
		vec4 viewPos = iProjDiag * ndcPos.xyzz + gbufferProjectionInverse[3];
		return viewPos.xyz / viewPos.w;
	}
	// END OF COMPLEMENTARY REIMAGINED`S CODE
	
	#ifdef DISTANT_HORIZONS
		vec3 screenToViewDh(vec3 screenPos) {
			vec3 ndcPos = screenPos * 2.0 - 1.0;
			vec4 iProjDiag = vec4(
				dhProjectionInverse[0].x,
				dhProjectionInverse[1].y,
				dhProjectionInverse[2].zw
			);
			vec4 viewPos = iProjDiag * ndcPos.xyzz + dhProjectionInverse[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
	#ifdef VOXY
		vec3 screenToViewVx(vec3 screenPos) {
			vec3 ndcPos = screenPos * 2.0 - 1.0;
			vec4 iProjDiag = vec4(
				vxProjInv[0].x,
				vxProjInv[1].y,
				vxProjInv[2].zw
			);
			vec4 viewPos = iProjDiag * ndcPos.xyzz + vxProjInv[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
#elif PROJECTION_TYPE == 1
	
	
	
	const float paniniScale = 0.5;
	const vec3 paniniCameraPos = vec3(0, 0, paniniScale);
	
	
	
	vec4 viewToNdc(vec3 viewPos) {
		
		vec3 cylinderPos = viewPos / length(viewPos.xz);
		vec3 newViewDir = cylinderPos - paniniCameraPos;
		vec3 newViewPos = normalize(newViewDir) * length(viewPos);
		vec4 ndcPos = PROJECTION_MATRIX * vec4(newViewPos, 1.0);
		
		vec3 cornerScreenPos = vec3(1.0, 1.0, 0.5);
		vec3 cornerViewPos = mult(INVERSE_PROJECTION_MATRIX, cornerScreenPos);
		vec3 cornerCylinderPos = cornerViewPos / length(cornerViewPos.xz);
		vec3 newCornerViewDir = cornerCylinderPos - paniniCameraPos; // the scale/length (aka dist from camera) doesn't matter here
		vec3 newCornerScreenPos = mult(PROJECTION_MATRIX, newCornerViewDir);
		ndcPos.xy /= newCornerScreenPos.xy;
		
		return ndcPos;
	}
	
	vec3 screenToView(vec3 screenPos) {
		vec3 ndcPos = screenPos * 2.0 - 1.0;
		
		vec3 cornerScreenPos = vec3(1.0, 1.0, 0.5);
		vec3 cornerViewPos = mult(INVERSE_PROJECTION_MATRIX, cornerScreenPos);
		vec3 cornerCylinderPos = cornerViewPos / length(cornerViewPos.xz);
		vec3 newCornerViewDir = cornerCylinderPos - paniniCameraPos; // the scale/length (aka dist from camera) doesn't matter here
		vec3 newCornerScreenPos = mult(PROJECTION_MATRIX, newCornerViewDir);
		ndcPos.xy *= newCornerScreenPos.xy;
		
		vec3 viewPos = mult(INVERSE_PROJECTION_MATRIX, ndcPos);
		viewPos += paniniCameraPos;
		viewPos = normalize(viewPos);
		float x = viewPos.x;
		float z = -viewPos.z;
		float c = -paniniCameraPos.z;
		float x2 = x * x;
		float x4 = x2 * x2;
		float z2 = z * z;
		float c2 = c * c;
		float newX = (sign(x) * sqrt(-c2 * x4 + c2 * x2 + 2.0 * c * x2 * z + x4 + x2 * z2) + c2 * x + c * x * z) / (c2 + 2.0 * c * z + x2 + z2);
		float newZ = sqrt(1.0 - newX * newX);
		vec3 cylinderPos = vec3(newX, viewPos.y * newX / viewPos.x, -newZ);
		vec3 newViewPos = normalize(cylinderPos) * length(viewPos);
		
		return newViewPos;
	}
	
	#ifdef DISTANT_HORIZONS
		vec3 screenToViewDh(vec3 screenPos) {
			vec4 iProjDiag = vec4(
				dhProjectionInverse[0].x,
				dhProjectionInverse[1].y,
				dhProjectionInverse[2].zw
			);
			vec3 ndcPos = screenPos * 2.0 - 1.0;
			vec4 viewPos = iProjDiag * ndcPos.xyzz + dhProjectionInverse[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
	#ifdef VOXY
		vec3 screenToViewVx(vec3 screenPos) {
			vec4 iProjDiag = vec4(
				vxProjInv[0].x,
				vxProjInv[1].y,
				vxProjInv[2].zw
			);
			vec3 ndcPos = screenPos * 2.0 - 1.0;
			vec4 viewPos = iProjDiag * ndcPos.xyzz + vxProjInv[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
	
	
#elif PROJECTION_TYPE == 2
	
	
	
	vec3 getIsometricScale() {
		const float invScale = 1.0 / (ISOMETRIC_WORLD_SCALE * 0.5);
		const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		return vec3(invScale * invAspectRatio, invScale, -1.0 / forwardPlusBackward);
	}
	
	float getIsometricZOffset() {
		return (ISOMETRIC_BACKWARD_VISIBILITY + 0.5) * 0.5;
		const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
		return forwardMinusBackward / forwardPlusBackward;
	}
	
	
	
	vec4 viewToNdc(vec3 viewPos) {
		vec3 screenPos = playerPos;
		screenPos.xyz *= getIsometricScale();
		screenPos.z -= getIsometricZOffset();
		return vec4(screenPos, 1.0);
	}
	
	vec3 screenToView(vec3 screenPos) {
		vec3 pos = screenPos * 2.0 - 1.0;
		pos.z += getIsometricZOffset();
		pos /= getIsometricScale();
		return pos;
	}
	
	vec2 reproject(vec3 screenPos, vec3 cameraOffset) {
		
		vec3 playerPos = screenPos * 2.0 - 1.0;
		playerPos.z += getIsometricOffset();
		playerPos /= getIsometricScale();
		playerPos = mat3(gbufferModelViewInverse) * playerPos;
		
		vec3 prevPlayerPos = playerPos + cameraOffset;
		
		vec2 prevCoord = (mat3(gbufferPreviousModelView) * prevPlayerPos).xy;
		prevCoord.xy *= getIsometricScale().xy;
		return prevCoord.xy * 0.5 + 0.5;
	}
	
	#ifdef DISTANT_HORIZONS
		vec3 screenToViewDh(vec3 pos) {
			pos = pos * 2.0 - 1.0;
			pos.z += getIsometricZOffset();
			pos /= getIsometricScale();
			return pos;
		}
	#endif
	
	#ifdef VOXY
		vec3 screenToViewVX(vec3 pos) {
			pos = pos * 2.0 - 1.0;
			pos.z += getIsometricZOffset();
			pos /= getIsometricScale();
			return pos;
		}
	#endif
	
	
	
#endif



vec4 playerToNdc(vec3 playerPos) {
	return viewToNdc(mat3(gbufferModelView) * playerPos);
}

vec2 reproject(vec3 screenPos, vec3 cameraOffset) {
	vec3 viewPos = screenToView(screenPos);
	vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 prevPlayerPos = playerPos + cameraOffset;
	vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevPlayerPos;
	vec4 prevCoord = gbufferPreviousProjection * vec4(prevViewPos, 1.0);
	return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
}
//vec2 reproject(vec3 screenPos, vec3 cameraOffset) {
//	screenPos = screenPos * 2.0 - 1.0;
//	vec4 viewPos = gbufferProjectionInverse * vec4(screenPos, 1.0);
//	vec3 playerPos = mat3(gbufferModelViewInverse) * (viewPos.xyz / viewPos.w);
	
//	vec3 prevPlayerPos = playerPos + cameraOffset;
//	vec3 prevViewPos = mat3(gbufferPreviousModelView) * prevPlayerPos;
//	vec4 prevCoord = gbufferPreviousProjection * vec4(prevViewPos, 1.0);
//	return prevCoord.xy / prevCoord.w * 0.5 + 0.5;
//}



#endif
