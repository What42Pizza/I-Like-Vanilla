#include "/utils/depth.glsl"



float getAoInfluence(float centerDepth, vec2 offset  ARGS_OUT) {
	
	float depth1 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord + offset).r  ARGS_IN);
	float depth2 = toBlockDepth(texture2D(DEPTH_BUFFER_WO_TRANS, texcoord - offset).r  ARGS_IN);
	//#ifdef DISTANT_HORIZONS
	//	depth1 = max(depth1, toBlockDepthDh(texture2D(DH_DEPTH_BUFFER_WO_TRANS, texcoord + offset).r  ARGS_IN));
	//	depth2 = max(depth2, toBlockDepthDh(texture2D(DH_DEPTH_BUFFER_WO_TRANS, texcoord - offset).r  ARGS_IN));
	//#endif
	float diff1 = centerDepth - depth1;
	float diff2 = centerDepth - depth2;
	
	float diffTotal = max(diff1 + diff2, 0.0);
	return float(diffTotal > 0.01);
	//diffTotal *= 4.0;
	//return (diffTotal * diffTotal) / pow(2.0, diffTotal);
}



float getAoFactor(float depth, float trueBlockDepth  ARGS_OUT) {
	
	float blockDepth = toBlockDepth(depth  ARGS_IN);
	//#ifdef DISTANT_HORIZONS
	//	blockDepth = max(blockDepth, toBlockDepthDh(texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r  ARGS_IN));
	//#endif
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	float noise = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0)) * PI * 2.0;
	float scale = AO_SIZE * 0.08 / blockDepth;
	
	float total = 0.0;
	const int SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 1; i <= SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / SAMPLE_COUNT + 0.75) * scale;
		#include "/import/invAspectRatio.glsl"
		vec2 offset = vec2(cos(i + noise) * len * invAspectRatio, sin(i + noise) * len);
		
		total += getAoInfluence(blockDepth, offset  ARGS_IN);
		
	}
	total /= SAMPLE_COUNT;
	#include "/import/invFar.glsl"
	total *= smoothstep(0.9, 0.8, trueBlockDepth * invFar);
	
	total *= total;
	total *= total;
	return total * 0.25;
}
