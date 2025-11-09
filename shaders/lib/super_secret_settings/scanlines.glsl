const float ScanlineBrightScale = 1.0;
const float ScanlineOffset = 0.0;



void sss_scanlines(inout vec3 color) {
	float InnerSine = texcoord.y * viewSize.y * 0.25 / SSS_SCANLINES_SCALE;
	float ScanBrightMod = sin(InnerSine * PI + ScanlineOffset * viewSize.y * 0.25);
	float ScanBrightness = ScanBrightMod * ScanBrightMod * ScanlineBrightScale;
	ScanBrightness = mix(1.0, ScanBrightness, SSS_SCANLINES_AMOUNT);
	color *= ScanBrightness;
}
