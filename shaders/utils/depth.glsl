#ifndef INCLUDE_DEPTH
#define INCLUDE_DEPTH



float toLinearDepth(float depth) {
	return twoTimesNear / (farPlusNear - depth * farMinusNear);
}

float fromLinearDepth(float depth) {
	return (farPlusNear - twoTimesNear / depth) * invFarMinusNear;
}

// Note: this is not exact
float toBlockDepth(float depth) {
	return mix(near, far, toLinearDepth(depth));
}



#ifdef DISTANT_HORIZONS
	
	float toLinearDepthDh(float depth) {
		return 2.0 * dhNearPlane / (dhFarPlane + dhNearPlane - depth * (dhFarPlane - dhNearPlane));
	}
	
	// Note: this is not exact
	float toBlockDepthDh(float depth) {
		return mix(dhRenderDistance * (dhNearPlane / dhFarPlane), dhRenderDistance, toLinearDepthDh(depth));
	}
	
#endif



#endif
