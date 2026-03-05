void doTaaJitter(inout vec2 pos) {
	pos += taaOffsetUniform * TAA_JITTER_AMOUNT * gl_Position.w;
}
