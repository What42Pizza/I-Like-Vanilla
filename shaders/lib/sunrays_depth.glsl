#include "/utils/depth.glsl"

float getDepthSunraysAmount() {
	
	//#ifdef GRADIENT_NOISE_SPEED
	//	#undef GRADIENT_NOISE_SPEED
	//#endif
	//#define GRADIENT_NOISE_SPEED 21.001
	//#include "/utils/var_gradient_noise.glsl"
	
	float noise = texelFetch(noisetex, (texelcoord + ivec2(frameCounter * 17, frameCounter * 27)) & 127, 0).b;
	
	vec2 pos = texcoord;
	vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY;
	
	#if DEPTH_SUNRAYS_STYLE == 1
		coordStep *= 1.0 - 0.5 * noise;
		
	#elif DEPTH_SUNRAYS_STYLE == 2
		pos += coordStep * (noise * 2.0 - 1.0);
		
	#endif
	
	float total = 0.0;
	for (int i = 1; i <= SUNRAYS_QUALITY; i++) {
		#if SUNRAYS_FLICKERING_FIX == 1
			if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) {
				total *= float(SUNRAYS_QUALITY) / i;
				break;
			}
		#endif
		bool isSky = texelFetch(DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r == 1.0;
		#ifdef DISTANT_HORIZONS
			isSky = isSky && texelFetch(DH_DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r == 1.0;
		#endif
		total += float(isSky) / SUNRAYS_QUALITY;// * float(i) / SUNRAYS_QUALITY / SUNRAYS_QUALITY; // once for `+= i / end_i`, and once for `total /= end_i`
		pos += coordStep;
	}
	
	float sunraysAmount = total * total;
	sunraysAmount *= max(1.0 - length(lightCoord - 0.5) * 1.2, 0.0);
	sunraysAmount *= 1.0 / (1.0 + length(lightCoord - texcoord) * 4.0);
	
	return sunraysAmount * 0.5;
}
