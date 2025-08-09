void doSharpening(inout vec3 color, float depth  ARGS_OUT) {
	
	#ifdef END
		if (depth == 1.0) return;
	#endif
	
	#if SHARPENING_DETECT_SIZE == 3
		
		vec3 colorTotal = color * 0.5;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		colorTotal *= 2.0;
		vec3 blur = colorTotal / 7.784; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#elif SHARPENING_DETECT_SIZE == 5
		
		vec3 colorTotal = color * 0.5;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  2), 0).rgb * 0.574;
		colorTotal *= 2.0;
		vec3 blur = colorTotal / 14.94; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#elif SHARPENING_DETECT_SIZE == 7
		
		vec3 colorTotal = color * 0.5;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -3), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2, -2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2, -2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-3, -1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0, -1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1, -1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2, -1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 3, -1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-3,  0), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  0), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2,  0), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 3,  0), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-3,  1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  1), 0).rgb * 0.895;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  1), 0).rgb * 0.801;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2,  1), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 3,  1), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-2,  2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  2), 0).rgb * 0.641;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  2), 0).rgb * 0.574;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 2,  2), 0).rgb * 0.411;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2(-1,  3), 0).rgb * 0.329;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 0,  3), 0).rgb * 0.368;
		colorTotal += texelFetch(MAIN_TEXTURE_COPY, texelcoord + ivec2( 1,  3), 0).rgb * 0.329;
		colorTotal *= 2.0;
		vec3 blur = colorTotal / 20.688; // value is pre-calculated total of weights + 1 (weights are gaussian of (offset length over 3))
		
	#endif
	
	#if FXAA_ENABLED == 1
		const float alteredSharpenAmount = SHARPEN_AMOUNT * 1.5;
		const float alteredSharpenVelocityAddition = SHARPEN_VEL_ADDITION * 1.25;
		const float alteredSharpenDepthAddition = SHARPEN_DEPTH_ADDITION * 1.2;
	#else
		const float alteredSharpenAmount = SHARPEN_AMOUNT;
		const float alteredSharpenVelocityAddition = SHARPEN_VEL_ADDITION;
		const float alteredSharpenDepthAddition = SHARPEN_DEPTH_ADDITION;
	#endif
	
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	#include "/import/far.glsl"
	float blockDepth = clamp(linearDepth * far - 8.0, 0.0, 128.0);
	
	#include "/import/sharpenVelocityFactor.glsl"
	float velocityFactor = sharpenVelocityFactor * alteredSharpenVelocityAddition;
	float depthAddition = alteredSharpenDepthAddition * 0.033 + velocityFactor * 0.02;
	float sharpenAmount = alteredSharpenAmount * 0.36 + sqrt(blockDepth) * depthAddition + velocityFactor * 0.37;
	color = mix(color, blur, -sharpenAmount); // exaggerate the difference between the image and the blurred image
	
}
