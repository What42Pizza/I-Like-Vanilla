#include "/utils/depth.glsl"

float getDepthSunraysAmount(ARG_OUT) {
	
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	
	#if DEPTH_SUNRAYS_STYLE == 1
		vec2 pos = texcoord;
		float noise = 1.0 - 0.3 * dither;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY * noise;
		
	#elif DEPTH_SUNRAYS_STYLE == 2
		vec2 pos = texcoord;
		vec2 coordStep = (lightCoord - pos) / SUNRAYS_QUALITY;
		float noise = (dither * 2.0 - 1.0) * 0.7;
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
	
	float sunraysAmount = sqrt(total);
	sunraysAmount *= max(1.0 - length(lightCoord - 0.5) * 1.5, 0.0);
	
	float dx = dFdx(sunraysAmount);
	if (int(gl_FragCoord.x) % 2 == 1) dx = -dx;
	sunraysAmount += dx * 0.25;
	float dy = dFdy(sunraysAmount);
	if (int(gl_FragCoord.y) % 2 == 1) dy = -dy;
	sunraysAmount += dy * 0.25;
	
	return sunraysAmount * 0.5;
}
