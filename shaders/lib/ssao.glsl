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
	diffTotal *= 4.0;
	return (diffTotal * diffTotal) / pow(2.0, diffTotal);
}



float getAoFactor(float depth, float trueBlockDepth  ARGS_OUT) {
	
	float blockDepth = toBlockDepth(depth  ARGS_IN);
	//#ifdef DISTANT_HORIZONS
	//	blockDepth = max(blockDepth, toBlockDepthDh(texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r  ARGS_IN));
	//#endif
	float dither = bayer64(gl_FragCoord.xy);
	#include "/import/frameCounter.glsl"
	float noise = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0)) * PI * 2.0;
	float scale = AO_SIZE * 0.1 / blockDepth;
	
	float total = 0.0;
	float maxTotal = 0.0; // this doesn't seem to have any performance impact vs total/=SAMPLE_COUNT at the end, so it's probably being pre-computed at comp-time
	const int SAMPLE_COUNT = AO_QUALITY * AO_QUALITY;
	for (int i = 1; i <= SAMPLE_COUNT; i ++) {
		
		float len = (float(i) / SAMPLE_COUNT + 0.3) * scale;
		#include "/import/invAspectRatio.glsl"
		vec2 offset = vec2(cos(i + noise) * len * invAspectRatio, sin(i + noise) * len);
		
		float weight = 100 - float(i) / SAMPLE_COUNT;
		total += getAoInfluence(blockDepth, offset  ARGS_IN) * weight;
		maxTotal += weight;
		
	}
	total /= maxTotal;
	#include "/import/invFar.glsl"
	total *= smoothstep(0.9, 0.8, trueBlockDepth * invFar);
	
	return total * 0.23;
}
