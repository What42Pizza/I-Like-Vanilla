uint rng =
	uint(gl_FragCoord.x) +
	uint(gl_FragCoord.y) * uint(viewWidth) +
	uint(frameCounter  ) * uint(viewWidth) * uint(viewHeight);
