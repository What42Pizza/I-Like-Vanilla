void doNeighborClamping(vec3 color, inout vec3 prevColor, vec2 prevCoord) {
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

//Catmull-Rom sampling from Complementary, which was taken from Filmic SMAA presentation (https://advances.realtimerendering.com/s2016/Filmic%20SMAA%20v7.pptx)
vec3 textureCatmullRom(sampler2D colortex, vec2 texcoord) {
	vec2 position = texcoord * viewSize;
	vec2 centerPosition = floor(position - 0.5) + 0.5;
	vec2 f = position - centerPosition;
	vec2 f2 = f * f;
	vec2 f3 = f * f2;
	
	float c = 0.5;
	vec2 w0 =        -c  * f3 +  2.0 * c         * f2 - c * f;
	vec2 w1 =  (2.0 - c) * f3 - (3.0 - c)        * f2         + 1.0;
	vec2 w2 = -(2.0 - c) * f3 + (3.0 -  2.0 * c) * f2 + c * f;
	vec2 w3 =         c  * f3 -                c * f2;
	
	vec2 w12 = w1 + w2;
	vec2 tc12 = (centerPosition + w2 / w12) * pixelSize;
	
	vec2 tc0 = (centerPosition - 1.0) * pixelSize;
	vec2 tc3 = (centerPosition + 2.0) * pixelSize;
	vec4 color = vec4(texture2DLod(colortex, vec2(tc12.x, tc0.y ), 0).rgb, 1.0) * (w12.x * w0.y ) +
				vec4(texture2DLod(colortex, vec2(tc0.x,  tc12.y), 0).rgb, 1.0) * (w0.x  * w12.y) +
				vec4(texture2DLod(colortex, vec2(tc12.x, tc12.y), 0).rgb, 1.0) * (w12.x * w12.y) +
				vec4(texture2DLod(colortex, vec2(tc3.x,  tc12.y), 0).rgb, 1.0) * (w3.x  * w12.y) +
				vec4(texture2DLod(colortex, vec2(tc12.x, tc3.y ), 0).rgb, 1.0) * (w12.x * w3.y );
	return color.rgb / color.a;
}

void doTemporalFilter(inout vec3 color, float depth, vec2 prevCoord) {
	
	if (
		prevCoord.x < 0.0 || prevCoord.x > 1.0 ||
		prevCoord.y < 0.0 || prevCoord.y > 1.0
	) return;
	
	vec3 prevColor = textureCatmullRom(PREV_TEXTURE, prevCoord).rgb * 2.0;
	
	doNeighborClamping(color, prevColor, prevCoord);
	
	const float blendStill = 0.8 * TEMPORAL_FILTER_STILL;
	const float blendMoving = 0.64 * TEMPORAL_FILTER_MOVING;
	
	const float blendMin = 0.3;
	const float blendMax = 0.98;
	const float blendVariable = blendStill - blendMoving;
	const float blendConstant = blendMoving;
	const float depthFactor = 0.006 * TEMPORAL_FILTER_DEPTH;
	
	vec2 velocity = (texcoord - prevCoord.xy) * viewSize;
	float velocityAmount = dot(velocity, velocity) * 8.0;
	
	float linearDepth = toLinearDepth(depth);
	float blendAmount = blendConstant + exp(-velocityAmount) * (blendVariable + sqrt(linearDepth * far) * depthFactor);
	blendAmount = clamp(blendAmount, blendMin, blendMax);
	
	color = mix(color, prevColor, blendAmount);
	
}
