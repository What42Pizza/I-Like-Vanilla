#if TONEMAPPER == 3
	#include "/lib/aces.glsl"
#endif



// custom tonemapper, probably trash according to color theory
vec3 simpleTonemapper(vec3 color  ARGS_OUT) {
	vec3 lowCurve = color * color;
	vec3 highCurve = 1.0 - 1.0 / (color * 10.0 + 1.0);
	return mix(lowCurve, highCurve, color);
}



void doColorCorrection(inout vec3 color  ARGS_OUT) {
	
	// brightness
	color *= (BRIGHTNESS - 1.0) / 1.5 + 1.0;
	
	// tonemapper
	color = max(color, 0.0);
	#if TONEMAPPER == 0
		color = min(color, vec3(1.0));
	#elif TONEMAPPER == 1
		color = smoothMin(color * 1.1, vec3(1.0), 0.03);
	#elif TONEMAPPER == 2
		color = simpleTonemapper(color  ARGS_IN);
	#elif TONEMAPPER == 3
		color = acesFitted(color);
	#endif
	
	#if USE_GAMMA_CORRECTION == 1
		color = sqrt(color);
	#endif
	
	// contrast
	color = mix(CONTRAST_DETECT_COLOR, color, CONTRAST * 0.1 + 1.0);
	color = clamp(color, 0.0, 1.0);
	
	// saturation & vibrance
	float maxChannel = max(max(color.r, color.g), color.b);
    float minChannel = min(min(color.r, color.g), color.b);
    float delta = maxChannel - minChannel;
    float saturation = (maxChannel == 0.0) ? 0.0 : delta / maxChannel;
    float vibranceAmount = pow2(1.0 - saturation) * VIBRANCE * 1.5;
	float colorLum = getColorLum(color);
	vec3 lumDiff = color - colorLum;
	float saturationAmount = (SATURATION + SATURATION_LIGHT * pow3(colorLum) + SATURATION_DARK * pow3(1 - colorLum) * 2.0) * 0.25;
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
	#endif
	
}
