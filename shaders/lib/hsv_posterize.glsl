float compress(float v, int quality) {
	const float slope = HSV_POSTERIZE_STEP_SLOPE;
	float sloped = (fract(v * quality) - 0.5) * slope + 0.5;
	sloped = clamp(sloped, 0.0, 1.0);
	return (sloped + floor(v * quality)) / quality;
}

//float compress(float v, int quality) { // creates optical illusion??
//	return v + 0.16 / quality * sin((2 * v + 1.0 / quality) * PI * quality);
//}



void doHsvPosterize(inout vec3 color, float depth) {
	bool isSky = depth == 1.0;
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		isSky = isSky && dhDepth == 1.0;
	#endif
	if (isSky) {return;}
	color = rgbToHsv(color);
	#if HSV_POSTERIZE_HUE_QUALITY > 0
		color.x = compress(color.x, HSV_POSTERIZE_HUE_QUALITY);
	#endif
	#if HSV_POSTERIZE_SATURATION_QUALITY > 0
		color.y = compress(color.y, HSV_POSTERIZE_SATURATION_QUALITY);
	#endif
	#if HSV_POSTERIZE_BRIGHTNESS_QUALITY > 0
		color.z = compress(color.z, HSV_POSTERIZE_BRIGHTNESS_QUALITY);
	#endif
	color = hsvToRgb(color);
}
