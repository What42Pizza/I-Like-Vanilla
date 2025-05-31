#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if SHARPENING_ENABLED == 1
	#include "/utils/depth.glsl"
#endif
#if SSS_DECONVERGE == 1
	#include "/lib/super_secret_settings/deconverge.glsl"
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
	
	#if SSS_DECONVERGE == 1
		vec3 color = sss_deconverge(ARG_IN);
	#else
		#if SSS_FLIP == 1
			#include "/import/viewSize.glsl"
			vec3 color = texelFetch(MAIN_TEXTURE_COPY, ivec2(viewSize) - texelcoord, 0).rgb;
		#else
			vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
		#endif
	#endif
	
	
	
	// ======== SHARPENING ======== //
	
	#if SHARPENING_ENABLED == 1
		doSharpening(color  ARGS_IN);
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
		doHsvPosterize(color  ARGS_IN);
	#endif
	
	
	
	// ======== VIGNETTE ======== //
	
	#if (VIGNETTE_ENABLED == 1 && !defined END) || HEALTH_EFFECT_ENABLED == 1 || DAMAGE_EFFECT_ENABLED == 1
		float vignetteAmount = length(texcoord - 0.5) * VIGNETTE_SCALE / sqrt(0.5);
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
			color.gb *= 1.0 - vignetteAmount * healthEffectAmount * HEALTH_EFFECT_STRENGTH * 0.5;
		#endif
		#if DAMAGE_EFFECT_ENABLED == 1
			#include "/import/damageAmount.glsl"
			color.gb *= 1.0 - vignetteAmount * damageAmount * DAMAGE_EFFECT_STRENGTH * 0.3;
		#endif
	#endif
	
	
	
	// super secret settings
	#if SSS_INVERT == 1
		color = 1.0 - color;
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
