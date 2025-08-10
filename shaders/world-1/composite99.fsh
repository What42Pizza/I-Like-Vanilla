#version 130

uniform sampler2D colortex7;
uniform sampler2D shadowtex0;

void main() {
	vec3 color = texelFetch(colortex7, ivec2(gl_FragCoord.xy), 0).rgb;
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}
