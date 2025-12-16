#include "/utils/depth.glsl"



float getAoInfluence(float centerDepth, vec2 offset) {
	
	float depth1 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord + offset).r);
	float depth2 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord - offset).r);
	
	float diff1 = centerDepth - depth1;
	float diff2 = centerDepth - depth2;
	
	float diffTotal = diff1 + diff2;
	return 1.0 - 2.0 * abs(clamp(diffTotal, 0.001, 1.0) - 0.5);
	
}



float getAoAmount(float depth) {
	
	float blockDepth = toBlockDepth(depth);
	vec3 noise3 = texelFetch(noisetex, (texelcoord + frameCounter * 17) & 127, 0).rgb;
	float fovScale = gbufferProjection[1][1];
	float scale = AO_SIZE * 0.25 / pow(blockDepth, 1.3) * fovScale;
	vec2 offsetOffset = noise3.xy * scale * 0.125;
	vec2 offsetMult = vec2(scale * invAspectRatio, scale);
	
	float total = 0.0;
	const int SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 1; i <= SAMPLE_COUNT; i++) {
		
		float len = float(i) / SAMPLE_COUNT;
		vec2 offset = vec2(cos(i + noise3.b), sin(i + noise3.b)) * len;
		offset *= offsetMult;
		offset += offsetOffset;
		
		total += getAoInfluence(blockDepth, offset);
		
	}
	total /= SAMPLE_COUNT;
	total *= clamp(blockDepth * invFar * -10.0 + 9.0, 0.0, 1.0);
	
	return total;
}
