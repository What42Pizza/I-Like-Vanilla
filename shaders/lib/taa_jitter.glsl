void doTaaJitter(inout vec2 pos) {
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += taaOffsetUniform * TAA_JITTER_AMOUNT * 0.7;
	#else
		pos += taaOffsetUniform * TAA_JITTER_AMOUNT * gl_Position.w;
	#endif
}
