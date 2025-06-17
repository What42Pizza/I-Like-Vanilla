void doVshLighting(float depth  ARGS_OUT) {
	
	#if HANDHELD_LIGHT_ENABLED == 1
		if (depth <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - depth / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	#ifdef SHADER_GBUFFERS_TERRAIN
		bool doSideShading = (materialId % 100) - (materialId % 10) != 10;
	#else
		const bool doSideShading = true;
	#endif
	
	if (doSideShading) {
		vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
		#ifdef SHADER_DH_TERRAIN
			const vec3 sideShadingVec = vec3(-0.8, 0.5, -0.5);
		#else
			const vec3 sideShadingVec = vec3(-0.5, 0.3, -0.25);
		#endif
		float sideShading = dot(shadingNormals, sideShadingVec);
		sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, max(lmcoord.x, lmcoord.y)) * 0.5;
		glcolor *= 1.0 + sideShading;
	} else {
		glcolor *= 1.1;
	}
	
	#if defined SHADER_GBUFFERS_TERRAIN || defined SHADER_GBUFFERS_WATER
		int brightnessDecreaseInt = ((materialId % 100000) - (materialId % 10000)) / 10000;
		float brightnessDecrease = brightnessDecreaseInt * 0.015 * BRIGHT_BLOCK_DECREASE;
		glcolor *= 1.0 - brightnessDecrease;
	#endif
	#ifdef SHADER_DH_TERRAIN
		if (dhMaterialId == DH_BLOCK_SAND) glcolor.rgb *= 1.0 - 9.0 * 0.015 * BRIGHT_BLOCK_DECREASE;
	#endif
	
}
