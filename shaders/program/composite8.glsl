in_out vec2 texcoord;



#ifdef FSH

#include "/lib/super_secret_settings/ntsc_encode.glsl"

void main() {
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = getNtscEncoded();
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
