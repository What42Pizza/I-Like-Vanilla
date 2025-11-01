// transfers

#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	flat in_out vec3 colorMult;
	in_out vec3 playerPos;
	
#endif



#ifdef FSH

#ifdef DISTANT_HORIZONS
	#include "/utils/depth.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a < 0.1) discard;
	
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float blockDepthDh = toBlockDepthDh(depthDh  ARGS_IN);
		if (blockDepthDh < length(playerPos)) discard;
	#endif
	
	float playerPosDist = max(length(playerPos.xz), abs(playerPos.y));
	color.a = 1.0 - mix(NEARBY_CLOUD_TRANSPARENCY, VANILLA_CLOUD_TRANSPARENCY, clamp(playerPosDist / NEARBY_CLOUD_DIST, 0.0, 1.0));
	
	
	color.rgb *= colorMult;
	float dist = max(max(abs(playerPos.x), abs(playerPos.y)), abs(playerPos.z));
	float mult = clamp(1.6 * (1.0 - dist / 1700.0), 0.0, 1.0);
	color.a *= mult * mult;
	
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
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

#include "/utils/getShadowcasterLight.glsl"
#include "/utils/getCloudColor.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	
	#if REALISTIC_CLOUDS_ENABLED == 1
		gl_Position = vec4(1.0);
		return;
	#endif
	
	colorMult = getCloudColor(0.25 + 0.75 * gl_Color.r  ARGS_IN);
	
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
