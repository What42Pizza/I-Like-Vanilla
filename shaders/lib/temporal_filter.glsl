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
	vec3 minColor = color;
	vec3 maxColor = color;
	
	for (int i = 0; i < clampingOffsetCount; i++) {
		ivec2 offsetCoord = texelcoord + clampingOffsets[i];
		vec3 offsetColor = texelFetch(MAIN_TEXTURE, offsetCoord, 0).rgb;
		minColor = min(minColor, offsetColor);
		maxColor = max(maxColor, offsetColor);
	}
	
	prevColor = clamp(prevColor, minColor, maxColor);
}



void doTemporalFilter(inout vec3 color, float depth, vec2 prevCoord  ARGS_OUT) {
	
	if (
		prevCoord.x < 0.0 || prevCoord.x > 1.0 ||
		prevCoord.y < 0.0 || prevCoord.y > 1.0
	) {
		return;
	}
	
	vec3 prevColor = texture2D(PREV_TEXTURE, prevCoord).rgb;
	
	neighborhoodClamping(color, prevColor  ARGS_IN);
	
	//const float blendMin = 0.3;
	//const float blendMax = 0.98;
	const float blendVariable = 0.07;
	const float blendConstant = 0.73;
	const float depthFactor = 0.01;
	
	#include "/import/viewSize.glsl"
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float velocityAmount = dot(velocity, velocity) * 10.0;
	
	#include "/import/far.glsl"
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	float blendAmount = blendConstant + exp(-velocityAmount) * (blendVariable + sqrt(linearDepth * far) * depthFactor);
	//blendAmount = clamp(blendAmount, blendMin, blendMax); // this can sometimes fix things but I don't think it's needed
	
	color = mix(color, prevColor, blendAmount);
	
}
