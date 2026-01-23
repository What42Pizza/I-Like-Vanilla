in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
flat in_out vec3 normal;
in_out vec3 viewPos;

flat in_out vec3 shadowcasterLight;



#ifdef FSH

#include "/lib/lighting/simple_fsh_lighting.glsl"

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	color.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	
	doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, 0.3, viewPos, normal);
	
	
	/* DRAWBUFFERS:0 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	
}

#endif



#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal = gl_NormalMatrix * gl_Normal;
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	
	shadowcasterLight = getShadowcasterLight();
	
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
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
