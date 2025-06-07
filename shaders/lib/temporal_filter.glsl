//-------------------------------//
//        Temporal Filter        //
//-------------------------------//

// This code was originally taken from Complementary Reimagined
// Link: https://modrinth.com/shader/complementary-reimagined



#ifdef FIRST_PASS
	const int clampingOffsetCount = 8;
	ivec2 clampingOffsets[clampingOffsetCount] = ivec2[clampingOffsetCount](
		ivec2(-1, -1),
		ivec2( 0, -1),
		ivec2( 1, -1),
		ivec2(-1,  0),
		ivec2( 1,  0),
		ivec2(-1,  1),
		ivec2( 0,  1),
		ivec2( 1,  1)
	);
#endif



void neighborhoodClamping(vec3 color, inout vec3 prevColor  ARGS_OUT) {
	vec3 minColor = color * 0.5;
	vec3 maxColor = color * 0.5;
	
	for (int i = 0; i < clampingOffsetCount; i++) {
		ivec2 offsetCoord = texelcoord + clampingOffsets[i];
		vec3 offsetColor = texelFetch(MAIN_TEXTURE, offsetCoord, 0).rgb;
		minColor = min(minColor, offsetColor);
		maxColor = max(maxColor, offsetColor);
	}
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
	
	if (
		prevCoord.x < 0.0 || prevCoord.x > 1.0 ||
		prevCoord.y < 0.0 || prevCoord.y > 1.0
	) {
		return;
	}
	float prevDepth = texture2D(DEPTH_BUFFER_WO_TRANS, prevCoord).r;
	if (depthIsHand(prevDepth)) prevCoord = texcoord;
	
	vec3 prevColor = texture2D(PREV_TEXTURE, prevCoord).rgb * 2.0;
	
	neighborhoodClamping(color, prevColor  ARGS_IN);
	
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
