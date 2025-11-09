// This code was taken from: https://github.com/kosua20/MIDIVisualizer/blob/master/resources/shaders/fxaa.frag
// This file is distributed under the MIT license



void doFxaa(inout vec3 color, sampler2D tex) {
	float edgeThresholdMin = 0.03125;
	float edgeThresholdMax = 0.0625;
	float subpixelQuality = 0.75;
	int iterations = 12;
	
	float lumaCenter = getLum(color);
	float lumaDown  = getLum(texelFetch(tex, texelcoord + ivec2( 0, -1), 0).rgb) * 2.0;
	float lumaUp    = getLum(texelFetch(tex, texelcoord + ivec2( 0,  1), 0).rgb) * 2.0;
	float lumaLeft  = getLum(texelFetch(tex, texelcoord + ivec2(-1,  0), 0).rgb) * 2.0;
	float lumaRight = getLum(texelFetch(tex, texelcoord + ivec2( 1,  0), 0).rgb) * 2.0;
	
	float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
	float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
	
	float lumaRange = lumaMax - lumaMin;
	
	if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {
		float lumaDownLeft  = getLum(texelFetch(tex, texelcoord + ivec2(-1, -1), 0).rgb) * 2.0;
		float lumaUpRight   = getLum(texelFetch(tex, texelcoord + ivec2( 1,  1), 0).rgb) * 2.0;
		float lumaUpLeft    = getLum(texelFetch(tex, texelcoord + ivec2(-1,  1), 0).rgb) * 2.0;
		float lumaDownRight = getLum(texelFetch(tex, texelcoord + ivec2( 1, -1), 0).rgb) * 2.0;
		
		float lumaDownUp    = lumaDown + lumaUp;
		float lumaLeftRight = lumaLeft + lumaRight;
		
		float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
		float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
		float lumaRightCorners = lumaDownRight + lumaUpRight;
		float lumaUpCorners    = lumaUpRight   + lumaUpLeft;
		
		float edgeHorizontal =
			abs(-2.0 * lumaLeft + lumaLeftCorners)
			+ abs(-2.0 * lumaCenter + lumaDownUp) * 2.0
			+ abs(-2.0 * lumaRight + lumaRightCorners);
		float edgeVertical =
			abs(-2.0 * lumaUp + lumaUpCorners)
			+ abs(-2.0 * lumaCenter + lumaLeftRight) * 2.0
			+ abs(-2.0 * lumaDown + lumaDownCorners);
		
		bool isHorizontal = edgeHorizontal >= edgeVertical;
		
		float luma1 = isHorizontal ? lumaDown : lumaLeft;
		float luma2 = isHorizontal ? lumaUp : lumaRight;
		float gradient1 = luma1 - lumaCenter;
		float gradient2 = luma2 - lumaCenter;
		
		bool is1Steepest = abs(gradient1) >= abs(gradient2);
		float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));
		
		float stepLength = isHorizontal ? invViewSize.y : invViewSize.x;
		
		float lumaLocalAverage = 0.0;
		
		if (is1Steepest) {
			stepLength = - stepLength;
			lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
		} else {
			lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
		}
		
		vec2 currentUv = texcoord;
		if (isHorizontal) {
			currentUv.y += stepLength * 0.5;
		} else {
			currentUv.x += stepLength * 0.5;
		}
		
		vec2 offset = isHorizontal ? vec2(invViewSize.x, 0.0) : vec2(0.0, invViewSize.y);
		
		vec2 uv1 = currentUv - offset;
		vec2 uv2 = currentUv + offset;
		
		float lumaEnd1 = getLum(texture2D(tex, uv1).rgb) * 2.0;
		float lumaEnd2 = getLum(texture2D(tex, uv2).rgb) * 2.0;
		lumaEnd1 -= lumaLocalAverage;
		lumaEnd2 -= lumaLocalAverage;
		
		bool reached1 = abs(lumaEnd1) >= gradientScaled;
		bool reached2 = abs(lumaEnd2) >= gradientScaled;
		bool reachedBoth = reached1 && reached2;
		
		if (!reached1) {
			uv1 -= offset;
		}
		if (!reached2) {
			uv2 += offset;
		}
		
		if (!reachedBoth) {
			for (int i = 2; i < iterations; i++) {
				if (!reached1) {
					lumaEnd1 = getLum(texture2D(tex, uv1).rgb) * 2.0;
					lumaEnd1 = lumaEnd1 - lumaLocalAverage;
				}
				if (!reached2) {
					lumaEnd2 = getLum(texture2D(tex, uv2).rgb) * 2.0;
					lumaEnd2 = lumaEnd2 - lumaLocalAverage;
				}
				
				reached1 = abs(lumaEnd1) >= gradientScaled;
				reached2 = abs(lumaEnd2) >= gradientScaled;
				reachedBoth = reached1 && reached2;
				
				const float quality[12] = float[12] (1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);
				if (!reached1) {
					uv1 -= offset * quality[i];
				}
				if (!reached2) {
					uv2 += offset * quality[i];
				}
				
				if (reachedBoth) break;
			}
		}
		
		float distance1 = isHorizontal ? (texcoord.x - uv1.x) : (texcoord.y - uv1.y);
		float distance2 = isHorizontal ? (uv2.x - texcoord.x) : (uv2.y - texcoord.y);
		
		bool isDirection1 = distance1 < distance2;
		float distanceFinal = min(distance1, distance2);
		
		float edgeThickness = (distance1 + distance2);
		
		float pixelOffset = - distanceFinal / edgeThickness + 0.5;
		
		bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;
		
		bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;
		
		float finalOffset = correctVariation ? pixelOffset : 0.0;
		
		float lumaAverage = (1.0 / 12.0) * (2.0 * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
		float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
		float subPixelOffset2 = (-2.0 * subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
		float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;
		
		finalOffset = max(finalOffset, subPixelOffsetFinal);
		
		// Compute the final UV coordinates
		vec2 finalUv = texcoord;
		if (isHorizontal) {
			finalUv.y += finalOffset * stepLength;
		} else {
			finalUv.x += finalOffset * stepLength;
		}
		
		color = texture2D(tex, finalUv).rgb * 2.0;
	}
}
