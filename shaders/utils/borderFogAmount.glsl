#ifndef INCLUDE_BORDER_FOG_AMOUNT
#define INCLUDE_BORDER_FOG_AMOUNT



float getBorderFogAmount(vec3 playerPos, out float fogDistance) {
	
	fogDistance = max(length(playerPos.xz), abs(playerPos.y));
	fogDistance *= invFar;
	#ifdef OVERWORLD
		const float borderFogStart = BORDER_FOG_START_OVERWORLD;
	#elif defined NETHER
		const float borderFogStart = BORDER_FOG_START_NETHER;
	#elif defined END
		const float borderFogStart = BORDER_FOG_START_END;
	#endif
	float fogAmount = (fogDistance - borderFogStart) / (BORDER_FOG_END - borderFogStart);
	fogAmount = clamp(fogAmount, 0.0, 1.0);
	
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



#endif
