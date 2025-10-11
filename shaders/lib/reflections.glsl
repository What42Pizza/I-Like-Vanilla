void raytrace(out vec2 reflectionPos, out int error, vec3 viewPos, float initialDepth, vec3 reflectionDir, vec3 normal  ARGS_OUT) {
	initialDepth *= 0.9997;
    
	// basic setup
	#include "/import/gbufferProjection.glsl"
	vec3 screenPos = endMat(gbufferProjection * startMat(viewPos)) * 0.5 + 0.5;
	vec3 nextScreenPos = endMat(gbufferProjection * startMat(viewPos + reflectionDir)) * 0.5 + 0.5;
    
	// calculate the optimal stepVector that will stop at the screen edge
	vec3 stepVector = nextScreenPos - screenPos;
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
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	screenPos += stepVector * dither * REFLECTION_DITHER_AMOUNT;

	#if EXPERIMENTAL_FIXES == 1
		// gating parameters to avoid long, broken streaks
		const float MAX_RAY_DISTANCE = 24.0; // in view-space units
		const float BASE_THICKNESS = 0.06;   // view-space thickness tolerance near start
	#endif
    
	int hitCount = 0;
	for (int i = 0; i < REFLECTION_ITERATIONS; i++) {
        
		// sample scene depth (optionally excluding handheld/transparents when experimental fixes are enabled)
		float realDepth =
		#if EXPERIMENTAL_FIXES == 1
			texture2D(DEPTH_BUFFER_WO_TRANS_OR_HANDHELD, screenPos.xy).r;
		#else
			texture2D(DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
		#endif
		#ifdef DISTANT_HORIZONS
			vec3 realBlockViewPos = screenToView(vec3(screenPos.xy, realDepth)  ARGS_IN);
			float realDepthDh = texture2D(DH_DEPTH_BUFFER_WO_TRANS, screenPos.xy).r;
			vec3 realBlockViewPosDh = screenToViewDh(vec3(screenPos.xy, realDepthDh)  ARGS_IN);
			if (realBlockViewPosDh.z > realBlockViewPos.z) realBlockViewPos = realBlockViewPosDh;
			vec4 sampleScreenPos = gbufferProjection * vec4(realBlockViewPos, 1.0);
			realDepth = sampleScreenPos.z / sampleScreenPos.w * 0.5 + 0.5;
		#endif
		float realToScreen = screenPos.z - realDepth;
        
		#if EXPERIMENTAL_FIXES == 1
			// compute view-space positions for thickness and distance checks
			vec3 rayViewPos = screenToView(screenPos  ARGS_IN);
			vec3 sceneViewPos = screenToView(vec3(screenPos.xy, realDepth)  ARGS_IN);
			float travelDist = length(rayViewPos - viewPos);
			if (travelDist > MAX_RAY_DISTANCE) { error = 1; return; }
			// skip sky/background
			if (realDepth >= 0.9999) { screenPos += stepVector; continue; }
		#endif
        
		if (realToScreen > 0.0) {
			hitCount ++;
			#if EXPERIMENTAL_FIXES == 1
				// adaptive thickness grows with distance to prevent false hits far away
				float maxThickness = BASE_THICKNESS + travelDist * 0.02;
				float thickness = abs(rayViewPos.z - sceneViewPos.z);
				if (thickness <= maxThickness || hitCount >= 6) {
			#else
				if (hitCount >= 2) {
			#endif
					reflectionPos = screenPos.xy;
					error = 0;
					if (realDepth < initialDepth) {
						vec2 start = endMat(gbufferProjection * startMat(viewPos)).xy * 0.5 + 0.5;
						reflectionPos = mix(start, reflectionPos, dither);
					}
					return;
				}
            
			stepVector *= 0.5;
			screenPos -= stepVector;
		} else {
			screenPos += stepVector;
		}
	}
    
	error = 1;
}



void addReflection(inout vec3 color, vec3 viewPos, float initialDepth, vec3 normal, sampler2D texture, float reflectionStrength  ARGS_OUT) {
	
	vec3 reflectionDirection = reflect(normalize(viewPos), normalize(normal));
	vec2 reflectionPos;
	int error;
	raytrace(reflectionPos, error, viewPos, initialDepth, reflectionDirection, normal  ARGS_IN);
	
	float fresnel = 1.0 - abs(dot(normalize(viewPos), normal));
	fresnel *= fresnel;
	fresnel *= fresnel;
	reflectionStrength *= 1.0 - REFLECTION_FRESNEL * (1.0 - fresnel);
	vec3 skyColor = getSkyColor(reflectionDirection  ARGS_IN);
	#include "/import/eyeBrightnessSmooth.glsl"
	vec3 alteredSkyColor = skyColor * max(eyeBrightnessSmooth.x * 0.5 / 240.0 * 0.99, eyeBrightnessSmooth.y / 240.0 * 0.99);
	
	const float inputColorWeight = 0.2;
	
	vec3 reflectionColor;
	if (error == 0) {
		reflectionColor = texture2DLod(texture, reflectionPos, 0).rgb * 2.0;
		float fadeOutSlope = 1.0 / (max(normal.z, 0.0) + 0.0001);
		reflectionColor = mix(alteredSkyColor, reflectionColor, clamp(fadeOutSlope - fadeOutSlope * max(abs(reflectionPos.x * 2.0 - 1.0), abs(reflectionPos.y * 2.0 - 1.0)), 0.0, 1.0));
		#if EXPERIMENTAL_FIXES == 1
			// distance-based attenuation: farther hits contribute less
			float hitDepth = texture2D(DEPTH_BUFFER_WO_TRANS_OR_HANDHELD, reflectionPos).r;
			vec3 hitViewPos = screenToView(vec3(reflectionPos, hitDepth)  ARGS_IN);
			float distFade = clamp(1.0 - length(hitViewPos - viewPos) / 24.0, 0.0, 1.0);
			reflectionStrength *= distFade;
		#endif
	} else {
		reflectionColor = alteredSkyColor;
	}
	reflectionColor *= (1.0 - inputColorWeight) + color * inputColorWeight;
	color = mix(color, reflectionColor, reflectionStrength);
	
}
