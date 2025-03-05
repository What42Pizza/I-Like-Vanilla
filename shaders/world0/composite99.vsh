#version 330 compatibility

void main() {
	#ifdef COPY_DEBUG_TO_OUTPUT
		gl_Position = ftransform();
	#else
		gl_Position = vec4(-1.0);
	#endif
}
