#include "/utils/depth.glsl"

float getDepthSunraysAmount(inout uint rng  ARGS_OUT) {
	
	
	#if DEPTH_SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		float noise = (randomFloat(rng) - 1.0) * 0.2 + 1.0;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY * noise;
		
	#elif DEPTH_SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY;
		float noise = randomFloat(rng) * 0.7;
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
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, ivec2(pos * viewSize), 0).r;
		if (depthIsSky(toLinearDepth(depth  ARGS_IN))) {
			total += 1.0 + float(i) / SUNRAYS_QUALITY;
		}
		pos += coordStep;
	}
	total /= SUNRAYS_QUALITY;
	
	if (total > 0.0) total = max(total, 0.2);
	
	float sunraysAmount = sqrt(total);
	sunraysAmount *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
	
	return sunraysAmount * 0.5;
}
