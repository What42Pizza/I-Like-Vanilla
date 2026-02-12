in_out vec2 texcoord;



#ifdef FSH

#if SSS_DECONVERGE == 1
	#include "/lib/super_secret_settings/deconverge.glsl"
#endif

void main() {
	
	vec2 texcoord = texcoord;
	
	#if SSS_FLIP == 1
		texcoord = 1.0 - texcoord;
	#endif
	
	#if SSS_BARREL == 1
		texcoord = texcoord * 2.0 - 1.0;
		texcoord *= SSS_BARREL_AMOUNT * (length(texcoord) - 1.0) + 1.0;
		texcoord = texcoord * 0.5 + 0.5;
		if (texcoord != clamp(texcoord, 0.0, 1.0)) {
			gl_FragData[0] = vec4(0.0, 0.0, 0.0, 1.0);
			return;
		}
	#endif
	
	#if SSS_DECONVERGE == 1
		vec3 color = sss_deconverge(MAIN_TEXTURE, texcoord);
	#else
		vec3 color = texture2D(MAIN_TEXTURE, texcoord).rgb;
	#endif
	
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
