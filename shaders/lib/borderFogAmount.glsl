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
			#if BORDER_FOG_CURVE_OVERWORLD == 2
				fogAmount = pow2(fogAmount);
			#elif BORDER_FOG_CURVE_OVERWORLD == 3
				fogAmount = pow3(fogAmount);
			#elif BORDER_FOG_CURVE_OVERWORLD == 4
				fogAmount = pow4(fogAmount);
			#elif BORDER_FOG_CURVE_OVERWORLD == 5
				fogAmount = pow5(fogAmount);
			#endif
		#elif defined NETHER
			#if BORDER_FOG_CURVE_NETHER == 2
				fogAmount = pow2(fogAmount);
			#elif BORDER_FOG_CURVE_NETHER == 3
				fogAmount = pow3(fogAmount);
			#elif BORDER_FOG_CURVE_NETHER == 4
				fogAmount = pow4(fogAmount);
			#elif BORDER_FOG_CURVE_NETHER == 5
				fogAmount = pow5(fogAmount);
			#endif
		#elif defined END
			#if BORDER_FOG_CURVE_END == 2
				fogAmount = pow2(fogAmount);
			#elif BORDER_FOG_CURVE_END == 3
				fogAmount = pow3(fogAmount);
			#elif BORDER_FOG_CURVE_END == 4
				fogAmount = pow4(fogAmount);
			#elif BORDER_FOG_CURVE_END == 5
				fogAmount = pow5(fogAmount);
			#endif
		#endif
	}
	
	return fogAmount;
}
