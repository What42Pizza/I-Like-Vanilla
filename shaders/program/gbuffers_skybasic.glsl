#ifdef FIRST_PASS
	in_out vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
#endif



#ifdef FSH

#include "/utils/getSkyColor.glsl"

void main() {
	
	
	#include "/import/invViewSize.glsl"
	#include "/import/gbufferProjectionInverse.glsl"
	vec3 viewPos = endMat(gbufferProjectionInverse * vec4(gl_FragCoord.xy * invViewSize * 2.0 - 1.0, 1.0, 1.0));
	vec3 albedo = getSkyColor(normalize(viewPos), true  ARGS_IN);
	
	
	if (starData.a > 0.5) {
		albedo = starData.rgb;
		#if DARKEN_STARS_NEAR_BLOCKLIGHT == 1
			#include "/import/eyeBrightnessSmooth.glsl"
			float blockBrightness = eyeBrightnessSmooth.x / 240.0;
			blockBrightness = min(blockBrightness * 8.0, 1.0);
			albedo *= blockBrightness * (DARKENED_STARS_BRIGHTNESS - 1.0) + 1.0;
		#endif
	}
	
	
	/* DRAWBUFFERS:02 */
	gl_FragData[0] = vec4(albedo, 1.0);
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.3),
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.0),
		1.0
	);
	
}

#endif





#ifdef VSH

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	gl_Position = ftransform();
	bool isStar = gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0;
	starData = vec4(gl_Color.rgb * STARS_BRIGHTNESS, float(isStar));
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
}

#endif
