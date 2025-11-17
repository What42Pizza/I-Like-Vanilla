in_out vec2 texcoord;
in_out vec4 glcolor;



#ifdef FSH

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	color.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	
	/* DRAWBUFFERS:0 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	
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
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	vec4 pos = gl_Vertex;
	float horizontalAmount = pos.y * WEATHER_HORIZONTAL_AMOUNT * 0.5;
	pos.x += horizontalAmount;
	horizontalAmount *= 0.5;
	pos.z += horizontalAmount;
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = endMat(gbufferModelViewInverse * (gl_ModelViewMatrix * pos));
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * pos;
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	glcolor = gl_Color;
	
}

#endif
