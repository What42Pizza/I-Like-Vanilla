//------------------------------------//
//        ISOMETRIC PROJECTION        //
//------------------------------------//

// This code was originally taken from XorDev's Ortho Shaderpack
// Link: https://github.com/XorDev/Ortho-Shaderpack/tree/master



vec3 getIsometricScale(ARG_OUT) {
	const float scale = ISOMETRIC_WORLD_SCALE * 0.5;
	const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	#include "/import/aspectRatio.glsl"
	return vec3(1.0 / (scale * aspectRatio), 1.0 / scale, -1.0 / forwardPlusBackward);
}

float getIsometricOffset(ARG_OUT) {
	return (ISOMETRIC_BACKWARD_VISIBILITY + 0.5) * 0.5;
	const float forwardPlusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 + ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	const float forwardMinusBackward = ISOMETRIC_FORWARD_VISIBILITY * 0.5 - ISOMETRIC_BACKWARD_VISIBILITY * 0.5;
	return forwardMinusBackward / forwardPlusBackward;
}



vec4 projectIsometric(vec3 playerPos  ARGS_OUT) {
	#include "/import/gbufferModelView.glsl"
	vec3 screenPos = mat3(gbufferModelView) * playerPos;
	screenPos.xyz *= getIsometricScale(ARG_IN);
	screenPos.z -= getIsometricOffset(ARG_IN);
	return vec4(screenPos, 1.0);
}
