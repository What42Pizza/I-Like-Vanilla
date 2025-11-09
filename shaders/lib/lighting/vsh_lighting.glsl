void doVshLighting(float depth) {
	
	lmcoord *= 1.0 - 0.2 * darknessFactor;
	lmcoord = max(lmcoord - 1.5 * darknessLightFactor, 0.0);
	
	#if defined SHADER_GBUFFERS_TERRAIN || defined SHADER_GBUFFERS_WATER
		int brightnessDecreaseInt = ((materialId % 100000) - (materialId % 10000)) / 10000;
		float brightnessDecrease = brightnessDecreaseInt * 0.017 * BRIGHT_BLOCK_DECREASE;
		glcolor *= 1.0 - brightnessDecrease;
	#endif
	#ifdef SHADER_DH_TERRAIN
		if (dhMaterialId == DH_BLOCK_SAND) glcolor.rgb *= 1.0 - 9.0 * 0.017 * BRIGHT_BLOCK_DECREASE;
	#endif
	
}
