#ifndef INCLUDE_DEPTH
#define INCLUDE_DEPTH



float toLinearDepth(float depth) {
	return twoTimesNear / (farPlusNear - depth * farMinusNear);
}

float fromLinearDepth(float depth) {
	return (farPlusNear - twoTimesNear / depth) * invFarMinusNear;
}

float toBlockDepth(float depth) {
	return mix(near, far, toLinearDepth(depth));
}



#ifdef DISTANT_HORIZONS
	
	float toLinearDepthDh(float depth) {
		return 2.0 * dhNearPlane / (dhFarPlane + dhNearPlane - depth * (dhFarPlane - dhNearPlane));
	}
	
	float toBlockDepthDh(float depth) {
		return mix(dhNearPlane, dhFarPlane, toLinearDepthDh(depth));
	}
	
#endif



#endif
