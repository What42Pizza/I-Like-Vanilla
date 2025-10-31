#define import_frameCounter

#ifdef FIRST_PASS
	float noise = 0;
#else
	float noise = fract(52.9829189 * fract(0.06711056 * (gl_FragCoord.x + frameCounter * GRADIENT_NOISE_SPEED) + 0.00583715 * (gl_FragCoord.y + frameCounter * GRADIENT_NOISE_SPEED)));
#endif
