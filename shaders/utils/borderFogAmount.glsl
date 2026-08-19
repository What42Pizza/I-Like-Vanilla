#ifndef INCLUDE_BORDER_FOG_AMOUNT
#define INCLUDE_BORDER_FOG_AMOUNT


float getBorderFogDistance(vec3 playerPos) {
	float fogDistance = max(length(playerPos.xz), abs(playerPos.y));
	#ifdef DISTANT_HORIZONS
		fogDistance /= dhRenderDistance;
	#elif defined VOXY
		fogDistance /= (vxRenderDistance - 4) * 16.0 * VOXY_BORDER_FOG_DIST_MULT;
	#else
		fogDistance *= invFar;
	#endif
	return fogDistance;
}

float getBorderFogAmount(float fogDistance) {
	#ifdef OVERWORLD
		float borderFogStart = BORDER_FOG_START_OVERWORLD;
	#elif defined NETHER
		float borderFogStart = BORDER_FOG_START_NETHER;
	#elif defined END
		float borderFogStart = BORDER_FOG_START_END;
	#endif
	#ifdef DISTANT_HORIZONS
		borderFogStart *= 0.25;
	#endif
	float fogAmount = percentThrough(fogDistance, borderFogStart, BORDER_FOG_END);
	
	if (isEyeInWater == 0) {
		#ifdef OVERWORLD
			#define BORDER_FOG_CURVE BORDER_FOG_CURVE_OVERWORLD
		#elif defined NETHER
			#define BORDER_FOG_CURVE BORDER_FOG_CURVE_NETHER
		#elif defined END
			#define BORDER_FOG_CURVE BORDER_FOG_CURVE_END
		#endif
		#if BORDER_FOG_CURVE == 2
			fogAmount = pow2(fogAmount);
		#elif BORDER_FOG_CURVE == 3
			fogAmount = pow3(fogAmount);
		#elif BORDER_FOG_CURVE == 4
			fogAmount = pow4(fogAmount);
		#elif BORDER_FOG_CURVE == 5
			fogAmount = pow5(fogAmount);
		#endif
	}
	
	return fogAmount;
}

float getBorderFogAmount(vec3 playerPos) {
	float fogDistance = getBorderFogDistance(playerPos);
	return getBorderFogAmount(fogDistance);
}

#endif
