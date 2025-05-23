#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

void main() {
	
	vec2 barrelTexCoord = texcoord * 2.0 - 1.0;
	barrelTexCoord *= SSS_BARREL_AMOUNT * (length(barrelTexCoord) - 1) + 1.0;
	barrelTexCoord = barrelTexCoord * 0.5 + 0.5;
	
	vec3 color = texture2D(MAIN_TEXTURE, barrelTexCoord).rgb;
	if (barrelTexCoord != clamp(barrelTexCoord, 0.0, 1.0)) color = vec3(0.0);
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
