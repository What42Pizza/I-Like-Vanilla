#include "/utils/screen_to_view.glsl"



vec3 getShadowPos(vec3 viewPos  ARGS_OUT) {
	#include "/import/gbufferModelViewInverse.glsl"
	vec4 playerPos = gbufferModelViewInverse * startMat(viewPos);
	#include "/import/shadowProjection.glsl"
	#include "/import/shadowModelView.glsl"
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; // convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos);
	shadowPos = distort(shadowPos, distortFactor); // apply shadow distortion
	shadowPos = shadowPos * 0.5 + 0.5;
	return shadowPos;
}



float getVolSunraysAmount(vec3 viewPos  ARGS_OUT) {
	const int SAMPLE_COUNT = int(SUNRAYS_QUALITY * SUNRAYS_QUALITY);
	
	float blockDepth = length(viewPos);
	vec3 viewPosStep = normalize(viewPos) * (blockDepth / SAMPLE_COUNT);
	vec3 pos = vec3(0.0);
	
	float dither = bayer64(gl_FragCoord.xy);
	#if TEMPORAL_FILTER_ENABLED == 1
		#include "/import/frameCounter.glsl"
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	pos += viewPosStep * (dither - 0.5);
	
	float total = 0.0;
	for (int i = 0; i < SAMPLE_COUNT; i ++) {
		
		vec3 shadowPos = getShadowPos(pos  ARGS_IN);
		float diff = texture2D(shadowtex0, shadowPos.xy).r - shadowPos.z;
		if (diff > 0.0) {
			total += 1.0;
		} else {
			total *= 1.0 + diff;
		}
		
		pos += viewPosStep;
		
	}
	float sunraysAmount = total / SAMPLE_COUNT * blockDepth;
	
	#include "/import/eyeBrightnessSmooth.glsl"
	float skyBrightness = eyeBrightnessSmooth.y / 240.0;
	sunraysAmount += (sunraysAmount > 0.0 ? 1.0 : 0.0) * mix(SUNRAYS_MIN_UNDERGROUND, SUNRAYS_MIN_SURFACE, skyBrightness);
	sunraysAmount *= 0.01;
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = (gbufferModelViewInverse * startMat(pos)).xyz;
	
	return sunraysAmount;
}
