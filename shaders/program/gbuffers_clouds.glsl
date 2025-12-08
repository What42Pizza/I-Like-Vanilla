in_out vec2 texcoord;
in_out vec3 playerPos;
in_out vec4 posXMin;
in_out vec4 posXMax;
in_out vec4 posYMin;
in_out vec4 posYMax;



#ifdef FSH

#include "/utils/getCloudColor.glsl"

#ifdef DISTANT_HORIZONS
	#include "/utils/depth.glsl"
#endif

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	if (color.a == 0.0) discard;
	
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float blockDepthDh = toBlockDepthDh(depthDh);
		if (blockDepthDh < length(playerPos)) discard;
	#endif
	
	float playerPosDist = max(length(playerPos.xz), abs(playerPos.y));
	color.a = 1.0 - mix(NEARBY_CLOUD_TRANSPARENCY, VANILLA_CLOUD_TRANSPARENCY, clamp(playerPosDist / NEARBY_CLOUD_DIST, 0.0, 1.0));
	
	
	vec3 posXMin = posXMin.xyz / posXMin.w;
	vec3 posXMax = posXMax.xyz / posXMax.w;
	vec3 posYMin = posYMin.xyz / posYMin.w;
	vec3 posYMax = posYMax.xyz / posYMax.w;
	vec3 xDir = posXMax - posXMin;
	vec3 yDir = posYMax - posYMin;
	vec3 normal = normalize(cross(yDir, xDir));
	normal.xz = abs(normal.xz);
	float normalFactor = mix(0.2, 0.1, betterRainStrength);
	color.rgb *= getCloudColor((1.0 - normalFactor) + normalFactor * dot(normal, normalize(vec3(0.5, 1.0, 0.0))));
	
	
	float dist = max(max(abs(playerPos.x), abs(playerPos.y)), abs(playerPos.z));
	float mult = clamp(1.6 * (1.0 - dist / 1700.0), 0.0, 1.0);
	color.a *= mult * mult;
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(0.0, 0.25),
		pack_2x8(0.0, 0.99),
		0.0, 1.0
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
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	playerPos = endMat(gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex);
	posXMin = vec4(0.0);
	posXMax = vec4(0.0);
	posYMin = vec4(0.0);
	posYMax = vec4(0.0);
	if (gl_VertexID % 4 == 0) { posXMin = vec4(playerPos, 1.0); posYMin = vec4(playerPos, 1.0); }
	if (gl_VertexID % 4 == 1) { posXMin = vec4(playerPos, 1.0); posYMax = vec4(playerPos, 1.0); }
	if (gl_VertexID % 4 == 2) { posXMax = vec4(playerPos, 1.0); posYMax = vec4(playerPos, 1.0); }
	if (gl_VertexID % 4 == 3) { posXMax = vec4(playerPos, 1.0); posYMin = vec4(playerPos, 1.0); }
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
}

#endif
