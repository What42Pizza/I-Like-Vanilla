in_out vec2 lmcoord;
flat in_out vec4 glcolor;
flat in_out vec2 encodedNormal;



#ifdef FSH

void main() {
	vec4 color = glcolor;
	if (color.a < 0.01) discard;
	
	/* DRAWBUFFERS:02 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.25, 0.25, 0.25, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_7_7_1_1(0.0, 0.3, 0.0, 0.0),
		encodedNormal
	);
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color;
	encodedNormal = encodeNormal(gbufferModelView[1].xyz);
	
	//glcolor.a = 0.5 + 0.5 * glcolor.a;
	if (glcolor.r + glcolor.b + glcolor.g < 0.1) {
		lmcoord = eyeBrightness / 512.0;
		lmcoord.x = max(lmcoord.x, heldBlockLightValue / 32.0);
		glcolor.a = 1.0 - max(lmcoord.x, lmcoord.y);
	}
	
	// taken from the vanilla rendertype_lines.vsh:
	float lineWidth = 1.5;
	const float VIEW_SHRINK = 1.0 - (1.0 / 256.0);
	const mat4 VIEW_SCALE = mat4(
		VIEW_SHRINK, 0.0, 0.0, 0.0,
		0.0, VIEW_SHRINK, 0.0, 0.0,
		0.0, 0.0, VIEW_SHRINK, 0.0,
		0.0, 0.0, 0.0, 1.0
	);
	vec4 linePosStart = gl_ProjectionMatrix * VIEW_SCALE * gl_ModelViewMatrix * vec4(vaPosition, 1.0);
	vec4 linePosEnd = gl_ProjectionMatrix * VIEW_SCALE * gl_ModelViewMatrix * vec4(vaPosition + vaNormal, 1.0);
	vec3 ndc1 = linePosStart.xyz / linePosStart.w;
	vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;
	vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * viewSize);
	vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * lineWidth * pixelSize;
	lineOffset *= sign(lineOffset.x) * (1.0 - (gl_VertexID % 2) * 2.0);
	gl_Position = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
	
	gl_Position.z -= 0.0001;
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif

	
}

#endif
