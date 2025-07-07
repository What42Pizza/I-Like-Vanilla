#if TONEMAPPER == 3
	#include "/lib/aces.glsl"
#endif



void doColorCorrection(inout vec3 color  ARGS_OUT) {
	
	// brightness
	color *= (BRIGHTNESS - 1.0) * 0.5 + 1.0;
	
	// tonemapper
	color = max(color, 0.0);
	#if TONEMAPPER == 0
		color = min(color, 1.0);
	#elif TONEMAPPER == 1
		color = min(color, 1.5);
		color = color - (4.0 / 27.0) * color * color * color;
	#elif TONEMAPPER == 2
		float lum = getColorLum(color);
		color /= 1.0 + lum * 0.5;
	#elif TONEMAPPER == 3
		color = acesFitted(color);
	#endif
	
	#if USE_GAMMA_CORRECTION == 1
		color = sqrt(color);
	#endif
	
	// contrast
	color = mix(vec3(0.5), color, CONTRAST * 0.1 + 1.0);
	color = clamp(color, 0.0, 1.0);
	
	// saturation & vibrance
	float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float delta = maxChannel - minChannel;
    float saturation = (maxChannel == 0.0) ? 0.0 : delta / maxChannel;
    float vibranceAmount = pow2(1.0 - saturation) * VIBRANCE * 1.5;
	float colorLum = getColorLum(color);
	vec3 lumDiff = color - colorLum;
	float saturationAmount = (SATURATION + SATURATION_LIGHT * pow3(colorLum) + SATURATION_DARK * pow3(1.0 - colorLum) * 2.0) * 0.25;
	color += lumDiff * (saturationAmount + vibranceAmount);
	color = clamp(color, 0.0, 1.0);
	
	#if USE_GAMMA_CORRECTION == 1
		#if GAMMA == 0
			color = pow2(color);
		#else
			const float realGamma = float(GAMMA) / 10.0;
			const float gammaMult = 1.0 - realGamma / 2.0;
			color = pow(color, vec3(2.0 * gammaMult));
		#endif
	#elif GAMMA != 0
		const float realGamma = float(GAMMA) / 10.0;
		const float gammaMult = 1.0 - realGamma / 2.0;
		color = pow(color, vec3(gammaMult));
	#endif
	
}
