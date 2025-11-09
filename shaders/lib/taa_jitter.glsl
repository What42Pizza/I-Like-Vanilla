void doTaaJitter(inout vec2 pos) {
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += taaOffset * 0.7;
	#else
		#ifdef SHADER_GBUFFERS_BASIC
			pos += taaOffset * gl_Position.w * 0.5;
		#else
			pos += taaOffset * gl_Position.w;
		#endif
	#endif
}
