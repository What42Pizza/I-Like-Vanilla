void doVshLighting(float depth  ARGS_OUT) {
	
	#if HANDHELD_LIGHT_ENABLED == 1
		if (depth <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - depth / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			lmcoord.x = max(lmcoord.x, handLightBrightness);
		}
	#endif
	
	vec3 shadingNormals = gl_Normal.xyz;
	float ySign = sign(shadingNormals.y);
	shadingNormals *= shadingNormals; // this allows diagonal stuff (like grass) to be less affected
	shadingNormals *= shadingNormals;
	shadingNormals.y *= ySign;
	shadingNormals.y -= 0.1;
	float sideShading = dot(shadingNormals, vec3(-0.8, 0.35, -0.6));
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, max(lmcoord.x, lmcoord.y)) * 0.5;
	glcolor *= 1.0 + sideShading;
	#ifdef SHADER_DH_TERRAIN
		glcolor *= 1.0 - 0.15 * shadingNormals.x;
	#endif
	
}
