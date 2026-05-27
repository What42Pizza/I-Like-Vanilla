void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, vec3 reflectionDir, vec3 normal) {
	
	// basic setup
	vec3 screenPos = mult(gbufferProjection, viewPos) * 0.5 + 0.5;
	vec3 nextScreenPos = mult(gbufferProjection, viewPos - reflectionDir * pow(dot(viewPos, viewPos), 0.3)) * 0.5 + 0.5; // normally this would be pos+dir (and step=next-pos), but for some reason it works better this way
	
	// calculate the optimal stepVector that will stop at the screen edge
	vec3 stepVector = screenPos - nextScreenPos;
	stepVector /= length(stepVector.xy);
	if (abs(stepVector.x) > 0.0001) {
		float clampedStepX = clamp(stepVector.x, -screenPos.x, 1.0 - screenPos.x);
		stepVector.yz *= clampedStepX / stepVector.x;
		stepVector.x = clampedStepX;
	}
	if (abs(stepVector.y) > 0.0001) {
		float clampedStepY = clamp(stepVector.y, -screenPos.y, 1.0 - screenPos.y);
		stepVector.xz *= clampedStepY / stepVector.y;
		stepVector.y = clampedStepY;
	}
	stepVector /= (REFLECTION_ITERATIONS - 8); // ensure that the ray will reach the edge of the screen 8 steps early, allows for fine-tuning to not be cut short
	
	float dither = bayer64(gl_FragCoord.xy);
	#if TEMPORAL_FILTER_ENABLED == 1
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	screenPos += stepVector * (dither + length(viewPos) / 1024) * REFLECTION_DITHER_AMOUNT;
	
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
	vec3 absPlayerPos = abs(playerPos * worldNormal);
	float playerPosMax = max(absPlayerPos.x, max(absPlayerPos.y, absPlayerPos.z));
	float ratioUpperBound = 1.0 / (1.0 + playerPosMax * 12.0);
	ratioUpperBound = 1.0002 + ratioUpperBound * 0.009;
	
	int hitCount = 0;
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
		
		float realDepth = texture2D(DEPTH_BUFFER_WO_TRANS_OR_HANDHELD, screenPos.xy).r;
		#ifdef DISTANT_HORIZONS
			vec3 realBlockViewPos = screenToView(vec3(texcoord, realDepth));
			float realDepthDh = texture2D(DH_DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
			vec3 realBlockViewPosDh = screenToViewDh(vec3(texcoord, realDepthDh));
			if (realBlockViewPosDh.z > realBlockViewPos.z) realBlockViewPos = realBlockViewPosDh;
			vec4 sampleScreenPos = gbufferProjection * vec4(realBlockViewPos, 1.0);
			realDepth = sampleScreenPos.z / sampleScreenPos.w * 0.5 + 0.5;
		#endif
		//float realToScreen = screenPos.z - realDepth;
		
		float ratio = screenPos.z / realDepth;
		
		//if (realToScreen > 0.0 && realToScreen < sqrt(stepVector.z) * 0.5) {
		//if (realToScreen > 0.0 && (toLinearDepth(screenPos.z) - toLinearDepth(realDepth)) < toLinearDepth(realDepth) * 0.1) {
		//float linearScreenDepth = toLinearDepth(screenPos.z);
		//float linearRealDepth = toLinearDepth(realDepth);
		//float ratio = linearScreenDepth / linearRealDepth;
		
		//if (ratio > 0.999 && ratio < 1.05 + 0.5 * linearScreenDepth) {
		if (ratio > 1.0 && ratio < ratioUpperBound) {
		//if (realToScreen > 0.0 && ratio > 1.0 && ratio < 1.0 + 0.75 * toLinearDepth(screenPos.z)) {
			hitCount ++;
			if (hitCount >= 5) { // converged on point
				reflectionPos = screenPos.xy;
				error = 0;
				float depthWithHandheld = texture2D(DEPTH_BUFFER_ALL, screenPos.xy).r;
				if (depthIsHand(depthWithHandheld) && dot(viewPos, viewPos) > 2.5 + dither) error = 1;
				return;
			}
			screenPos -= stepVector;
			stepVector *= 0.5;
		} else {
			screenPos += stepVector;
		}
	}
	
	error = 1;
}



void addReflection(inout vec3 color, vec3 viewPos, vec3 normal, vec2 lmcoord, sampler2D texture, float reflectionStrength) {
	
	vec3 reflectionDirection = reflect(normalize(viewPos), normalize(normal));
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, reflectionDirection, normal);
	
	float fresnel = 1.0 - abs(dot(normalize(viewPos), normal));
	fresnel *= fresnel;
	fresnel *= fresnel;
	reflectionStrength *= 1.0 - REFLECTION_FRESNEL * (1.0 - fresnel);
	vec3 skyColor = getSkyColor(reflectionDirection, true);
	float maxBrightness = max(lmcoord.x * 0.75, lmcoord.y);
	#ifdef END
		maxBrightness = 0.5 + 0.5 * lmcoord.x;
	#endif
	skyColor *= maxBrightness * maxBrightness;
	if (isEyeInWater == 1) {
		reflectionStrength *= 0.5;
		skyColor = 0.08 + 0.125 * skyColor;
		skyColor += vec3(0.0, 0.03, 0.3);
	}
	
	vec3 reflectionColor;
	if (error == 0) {
		reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb * 2.0;
		float reflectionDepth = texelFetch(DEPTH_BUFFER_WO_TRANS, ivec2(reflectionPos * viewSize), 0).r;
		reflectionColor *= REFLECTIONS_BRIGHTNESS - (REFLECTIONS_BRIGHTNESS - 1.0) * step(1.0, reflectionDepth);
		float fadeOutSlope = 1.0 / (max(normal.z, 0.0) + 0.0001);
		reflectionColor = mix(skyColor, reflectionColor, clamp(fadeOutSlope - fadeOutSlope * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
	} else {
		reflectionColor = skyColor;
	}
	color = mix(color, reflectionColor, reflectionStrength);
	
}
