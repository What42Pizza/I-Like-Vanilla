// transfers

#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	flat in_out vec3 colorMult;
	in_out vec3 playerPos;
	
#endif



#ifdef FSH

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a < 0.1) discard;
	
	float playerPosDist = max(length(playerPos.xz), abs(playerPos.y));
	color.a = 1.0 - mix(NEARBY_CLOUD_TRANSPARENCY, VANILLA_CLOUD_TRANSPARENCY, clamp(playerPosDist / NEARBY_CLOUD_DIST, 0.0, 1.0));
	
	
	color.rgb *= colorMult;
	
	
	/* DRAWBUFFERS:03 */
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		packVec2(0.0, 0.25),
		packVec2(0.0, 0.0),
		packVec2(0.0, 0.99),
		1.0
	);
	
}

#endif



#ifdef VSH

#include "/utils/getShadowcasterColor.glsl"
#include "/utils/getCloudColor.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	
	#if REALISTIC_CLOUDS_ENABLED == 1
		gl_Position = vec4(10.0);
		return;
	#endif
	
	vec3 normal = gl_NormalMatrix * gl_Normal;
	#include "/import/sunPosition.glsl"
	#include "/import/moonPosition.glsl"
	#include "/import/dayPercent.glsl"
	float brightness = 0.725
		+ 0.1 * dot(normal, normalize(sunPosition)) * dayPercent
		+ 0.075 * dot(normal, normalize(moonPosition)) * (1.0 - dayPercent);
	colorMult = getCloudColor(brightness  ARGS_IN);
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#include "/import/gbufferModelViewInverse.glsl"
	playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
}

#endif
