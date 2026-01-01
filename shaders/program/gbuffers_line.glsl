in_out vec2 lmcoord;
flat in_out vec4 glcolor;
flat in_out vec2 encodedNormal;



#ifdef FSH

void main() {
	vec4 color = glcolor;
	if (color.a < 0.01) discard;
	color.a = 0.5 + 0.5 * color.a;
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(eyeBrightness / 240.0),
		pack_2x8(0.0, 0.3),
		encodedNormal
	);
}

#endif



#ifdef VSH

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	glcolor = gl_Color;
	encodedNormal = encodeNormal(gbufferModelView[1].xyz);
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
		gl_Position = projectIsometric(playerPos);
	#else
		float lineWidth = 0.002;
		gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition, 1.0);
		vec4 offsetPos = projectionMatrix * modelViewMatrix * vec4(vaPosition + vaNormal, 1.0);
		vec2 screenDir = offsetPos.xy / offsetPos.w - gl_Position.xy / gl_Position.w;
		screenDir = normalize(screenDir) * lineWidth;
		screenDir.xy = screenDir.yx;
		screenDir.x *= -1;
		screenDir *= sign(screenDir.x);
		screenDir.x *= invAspectRatio;
		screenDir *= (gl_VertexID % 2) * 2.0 - 1.0;
		gl_Position.xy += screenDir * gl_Position.w;
		gl_Position.z -= 0.0001;
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif

	
}

#endif
