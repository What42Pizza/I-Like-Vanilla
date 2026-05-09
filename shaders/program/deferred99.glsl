#ifdef FSH
void main() {
	/* RENDERTARGETS: 10 */
	gl_FragData[0] = vec4(1.0);
}
#endif



#ifdef VSH
void main() {
	gl_Position = ftransform();
}
#endif
