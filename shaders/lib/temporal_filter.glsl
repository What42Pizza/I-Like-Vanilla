void doNeighborClamping(vec3 color, inout vec3 prevColor  ARGS_OUT) {
	vec3 minColor = color * 0.5;
	vec3 maxColor = color * 0.5;
	
	#define CLAMP(x, y) { currSample = texelFetch(MAIN_TEXTURE, texelcoord + ivec2(x, y), 0).rgb; minColor = min(minColor, currSample); maxColor = max(maxColor, currSample); }
	
	vec3 currSample;
	CLAMP(-1, -1)
	CLAMP( 0, -1)
	CLAMP( 1, -1)
	CLAMP(-1,  0)
	CLAMP( 1,  0)
	CLAMP(-1,  1)
	CLAMP( 0,  1)
	CLAMP( 1,  1)
	
	minColor *= 2.0;
	maxColor *= 2.0;
	
	prevColor = clamp(prevColor, minColor, maxColor);
}

void doTemporalFilter(inout vec3 color, float depth, float dhDepth, vec2 prevCoord  ARGS_OUT) {
	
	#ifdef END
		#ifdef DISTANT_HORIZONS
			if (depth == 1.0 && dhDepth == 1.0) return;
		#else
			if (depth == 1.0) return;
		#endif
	#endif
	if (clamp(prevCoord, 0.0, 1.0) != prevCoord) return;
	
	float prevDepth = texture2D(DEPTH_BUFFER_WO_TRANS, prevCoord).r;
	if (depthIsHand(prevDepth)) prevCoord = texcoord;
	
	vec3 prevColor = texture2D(PREV_TEXTURE, prevCoord).rgb * 2.0;
	
	doNeighborClamping(color, prevColor  ARGS_IN);
	
	const float blendMin = 0.3;
	const float blendMax = 0.98;
	const float blendVariable = 0.08;
	const float blendConstant = 0.72;
	const float depthFactor = 0.012;
	
	#include "/import/viewSize.glsl"
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float velocityAmount = dot(velocity, velocity) * 10.0;
	
	#include "/import/far.glsl"
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	float blendAmount = blendConstant + exp(-velocityAmount) * (blendVariable + sqrt(linearDepth * far) * depthFactor);
	blendAmount = clamp(blendAmount, blendMin, blendMax);
	
	color = mix(color, prevColor, blendAmount);
	
}
