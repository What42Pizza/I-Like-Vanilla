void doVshLighting(vec3 viewPos, vec3 normal) {
	
	lmcoord *= 1.0 - 0.2 * darknessFactor;
	lmcoord = max(lmcoord - 1.5 * darknessLightFactor, 0.0);
	
	lmcoord.y = (lmcoord.y * lmcoord.y + lmcoord.y * 2.0) * 0.333; // kinda like squaring but not as intense
	
	#if HANDHELD_LIGHT_ENABLED == 1
		float viewPosLen = length(viewPos);
		if (viewPosLen <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - viewPosLen / HANDHELD_LIGHT_DISTANCE, 0.0);
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			#if BLOCKLIGHT_FLICKERING_ENABLED == 1
				handLightBrightness *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT * 0.1;
			#endif
			handLightBrightness *= 1.0 - HANDHELD_LIGHT_REALISM * (1.0 + dot(normalize(viewPos), normal));
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		lmcoord.x *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT * 0.1;
	#endif
	#ifdef OVERWORLD
		lmcoord.x *= 1.0 + (eyeBrightness.y / 240.0) * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	
}
