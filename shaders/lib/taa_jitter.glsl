void doTaaJitter(inout vec2 pos) {
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += taaOffsetUniform * 0.7;
	#else
		pos += taaOffsetUniform * gl_Position.w;
	#endif
}
