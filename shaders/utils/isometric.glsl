#ifndef INCLUDE_ISOMETRIC
#define INCLUDE_ISOMETRIC



vec3 getIsometricScale() {
	const float invScale = 1.0 / (ISOMETRIC_WORLD_SCALE * 0.5);
	const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	return vec3(invScale * invAspectRatio, invScale, -1.0 / forwardPlusBackward);
}

float getIsometricOffset() {
	return (ISOMETRIC_BACKWARD_VISIBILITY + 0.5) * 0.5;
	const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	return forwardMinusBackward / forwardPlusBackward;
}



vec4 projectIsometric(vec3 playerPos) {
	vec3 screenPos = mat3(gbufferModelView) * playerPos;
	screenPos.xyz *= getIsometricScale();
	screenPos.z -= getIsometricOffset();
	return vec4(screenPos, 1.0);
}



#endif
