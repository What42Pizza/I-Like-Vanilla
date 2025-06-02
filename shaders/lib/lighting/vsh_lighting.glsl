void doVshLighting(float depth  ARGS_OUT) {
	
	#if HANDHELD_LIGHT_ENABLED == 1
		if (depth <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - depth / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	vec3 shadingNormals = vec3(abs(gl_Normal.x), gl_Normal.y, abs(gl_Normal.z));
	float sideShading = dot(shadingNormals, vec3(-0.8, 0.3, -0.6));
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, max(lmcoord.x, lmcoord.y)) * 0.5;
	#ifdef SHADER_DH_TERRAIN
		sideShading *= 1.2;
	#endif
	glcolor *= 1.0 + sideShading;
	
}
