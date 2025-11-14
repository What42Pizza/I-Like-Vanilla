void doVshLighting(float depth) {
	
	lmcoord *= 1.0 - 0.2 * darknessFactor;
	lmcoord = max(lmcoord - 1.5 * darknessLightFactor, 0.0);
	
	lmcoord.y = (lmcoord.y * lmcoord.y + lmcoord.y) * 0.5; // kinda like squaring but not as intense
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		lmcoord.x *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT * 0.1;
	#endif
	#ifdef OVERWORLD
		lmcoord.x *= 1.0 + (eyeBrightness.y / 240.0) * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	
}
