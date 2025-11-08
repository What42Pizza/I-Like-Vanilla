#include "/utils/depth.glsl"

float getDepthSunraysAmount(ARG_OUT) {
	
	#ifdef GRADIENT_NOISE_SPEED
		#undef GRADIENT_NOISE_SPEED
	#endif
	#define GRADIENT_NOISE_SPEED 21.001
	#include "/utils/var_gradient_noise.glsl"
	
	#if DEPTH_SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		noise = 1.0 - 0.9 * noise;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY * noise;
		
	#elif DEPTH_SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY;
		noise = (noise * 2.0 - 1.0) * 0.75;
		pos += coordStep * noise;
		
	#endif
	
	float total = 0.0;
	for (int i = 1; i < SUNRAYS_QUALITY; i ++) {
		#if SUNRAYS_FLICKERING_FIX == 1
			if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0) {
				total *= float(SUNRAYS_QUALITY) / i;
				break;
			}
		#endif
		#include "/import/viewSize.glsl"
		bool isSky = texelFetch(DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r == 1.0;
		#ifdef DISTANT_HORIZONS
			isSky = isSky && texelFetch(DH_DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r == 1.0;
		#endif
		if (isSky) {
			total += 1.0 + float(i) / SUNRAYS_QUALITY;
		}
		pos += coordStep;
	}
	total /= SUNRAYS_QUALITY;
	
	if (total > 0.0) total = max(total, 0.2);
	
	float sunraysAmount = (total);
	sunraysAmount *= sunraysAmount;
	sunraysAmount *= max(1.0 - length(lightCoord - 0.5) * 1.2, 0.0);
	
	return sunraysAmount * 0.5;
}
