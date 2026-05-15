#ifdef FSH

void main() {
	vec2 data = texelFetch(MISC_DATA_TEXTURE, texelcoord, 0).rg;
	
	if (texelcoord == ivec2(0.0)) data = vec2(1.0);
	
	/* RENDERTARGETS: 10 */
	gl_FragData[0] = vec4(data, 0.0, 1.0);
}

#endif



#ifdef VSH
void main() {
	gl_Position = ftransform();
}
#endif
