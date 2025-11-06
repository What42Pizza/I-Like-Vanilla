#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if SHARPENING_ENABLED == 1 || KUWAHARA_ENABLED == 1
	#include "/utils/depth.glsl"
#endif
#if KUWAHARA_ENABLED == 1
	#include "/lib/kuwahara.glsl"
#endif
#if SHARPENING_ENABLED == 1
	#include "/lib/sharpening.glsl"
#endif
#include "/lib/color_correction.glsl"
#if COLORBLIND_MODE != 0
	#include "/lib/colorblindness.glsl"
#endif
#include "/lib/super_secret_settings/super_secret_settings.glsl"
#if HSV_POSTERIZE_ENABLED == 1
	#include "/lib/hsv_posterize.glsl"
#endif

void main() {
	
	//#if SHARPENING_ENABLED == 1 || HSV_POSTERIZE_ENABLED == 1 || KUWAHARA_ENABLED == 1
		float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	//#endif
	
	#if KUWAHARA_ENABLED == 1
		vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
		color = doKuwaharaEffect(color, MAIN_TEXTURE, depth  ARGS_IN) * 2.0;
	#else
		vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	#endif
	
	
	
	// ======== SHARPENING ======== //
	
	#if SHARPENING_ENABLED == 1
		doSharpening(color, depth  ARGS_IN);
	#endif
	
	
	
	// ======== COLOR CORRECTION & TONE MAPPING ======== //
	
	doColorCorrection(color  ARGS_IN);
	#if COLORBLIND_MODE != 0
		applyColorblindnessCorrection(color  ARGS_IN);
	#endif
	
	
	
	// ======== SUPER SECRET SETTINGS ======== //
	
	doSuperSecretSettings(color  ARGS_IN);
	
	
	
	// ======== HSV POSTERIZE ======== //
	
	#if HSV_POSTERIZE_ENABLED == 1
		doHsvPosterize(color, depth  ARGS_IN);
	#endif
	
	
	
	// ======== VIGNETTE ======== //
	
	#if (VIGNETTE_ENABLED == 1 && !defined END) || HEALTH_EFFECT_ENABLED == 1 || DAMAGE_EFFECT_ENABLED == 1
		float vignetteAmount = length(texcoord - 0.5) * VIGNETTE_SCALE;
		#if VIGNETTE_NOISE_ENABLED == 1
			#include "/utils/var_rng.glsl"
			vignetteAmount += randomFloat(rng) * 0.02;
		#endif
		#include "/import/eyeBrightnessSmooth.glsl"
		#if VIGNETTE_ENABLED == 1 && !defined END
			color *= 1.0 - vignetteAmount * mix(VIGNETTE_AMOUNT_UNDERGROUND, VIGNETTE_AMOUNT_SURFACE, eyeBrightnessSmooth.y / 240.0);
		#endif
		#if HEALTH_EFFECT_ENABLED == 1
			#include "/import/smoothPlayerHealth.glsl"
			float healthEffectAmount = 1.0 - smoothPlayerHealth;
			healthEffectAmount *= healthEffectAmount;
			healthEffectAmount *= vignetteAmount * HEALTH_EFFECT_STRENGTH * 0.7;
			color.gb *= 1.0 - healthEffectAmount;
			color.r += healthEffectAmount * 0.4;
		#endif
		#if DAMAGE_EFFECT_ENABLED == 1
			#include "/import/damageAmount.glsl"
			float damageEffectAmount = damageAmount;
			damageEffectAmount *= vignetteAmount * DAMAGE_EFFECT_STRENGTH * 0.5;
			color.gb *= 1.0 - damageEffectAmount;
			color.r += damageEffectAmount * 0.2;
		#endif
	#endif
	
	
	
	// super secret settings
	#if SSS_INVERT == 1
		color = 1.0 - color;
	#endif
	
	
	
	#include "/import/frameCounter.glsl"
	color += (fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y + 0.0003181 * frameCounter)) - 0.5) / 255.0;
	
	/* DRAWBUFFERS:07 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(depth, 0.0, 0.0, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
