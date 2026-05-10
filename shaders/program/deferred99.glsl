#ifdef FSH

void main() {
	vec2 output = texelFetch(MISC_DATA_TEXTURE, texelcoord, 0).rg;
	
	if (texelcoord == ivec2(0.0)) output = vec2(1.0);
	
	/* RENDERTARGETS: 10 */
	gl_FragData[0] = vec4(output, 0.0, 1.0);
}

#endif



#ifdef VSH
void main() {
	gl_Position = ftransform();
}
#endif
