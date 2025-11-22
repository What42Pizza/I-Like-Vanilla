#include "/utils/depth.glsl"



float getAoInfluence(float centerDepth, vec2 offset) {
	
	float depth1 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord + offset).r);
	float depth2 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord - offset).r);
	
	float diff1 = centerDepth - depth1;
	float diff2 = centerDepth - depth2;
	
	float diffTotal = max(diff1 + diff2, 0.0);
	return float(diffTotal > 0.001 && diffTotal < 1.0);
	
}



float getAoFactor(float depth) {
	
	float blockDepth = toBlockDepth(depth);
	float dither = bayer64(gl_FragCoord.xy);
	float noise = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0)) * PI * 2.0;
	float scale = AO_SIZE * 0.5 / blockDepth;
	
	float total = 0.0;
	const int SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 1; i <= SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / SAMPLE_COUNT + 0.0);
		len *= len;
		len *= scale;
		vec2 offset = vec2(cos(i + noise) * len * invAspectRatio, sin(i + noise) * len);
		
		total += getAoInfluence(blockDepth, offset);
		
	}
	total /= SAMPLE_COUNT;
	total *= clamp(blockDepth * invFar * -10.0 + 9.0, 0.0, 1.0);
	
	return total * 0.5;
}
