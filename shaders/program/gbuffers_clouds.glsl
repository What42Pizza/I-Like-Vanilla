#if CLOUD_COMPATIBILITY == 1
	in_out vec2 texcoord;
#endif
in_out vec3 playerPos;



#ifdef FSH

#include "/utils/getCloudColor.glsl"

#ifdef DISTANT_HORIZONS
	#include "/utils/depth.glsl"
#endif

void main() {
	
	#if CLOUD_COMPATIBILITY == 1
		vec4 color = texture2D(MAIN_TEXTURE, texcoord);
		if (color.a == 0.0) discard;
	#else
		vec4 color = vec4(1.0);
	#endif
	
	
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float blockDepthDh = toBlockDepthDh(depthDh);
		if (blockDepthDh < length(playerPos)) discard;
	#endif
	
	
	// nearby transparency
	float playerPosDist = max(length(playerPos.xz), abs(playerPos.y));
	color.a = 1.0 - mix(NEARBY_CLOUD_TRANSPARENCY, VANILLA_CLOUD_TRANSPARENCY, clamp(playerPosDist / NEARBY_CLOUD_DIST, 0.0, 1.0));
	
	
	// cloud color
	vec3 xDir = dFdx(playerPos);
	vec3 yDir = dFdy(playerPos);
	vec3 normal = normalize(cross(xDir, yDir));
	normal.xz = abs(normal.xz);
	float normalFactor = mix(0.2, 0.1, betterRainStrength);
	color.rgb *= getCloudColor((1.0 - normalFactor) + normalFactor * dot(normal, normalize(vec3(0.5, 1.0, 0.0))));
	
	
	// fog transparency
	float dist = max(max(abs(playerPos.x), abs(playerPos.y)), abs(playerPos.z));
	float mult = clamp(1.6 * (1.0 - dist / 1900.0), 0.0, 1.0);
	color.a *= mult * mult;
	
	
	/* DRAWBUFFERS:03 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.0, 1.0, 1.0, 1.0);
	#endif
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
	#if CLOUD_COMPATIBILITY == 1
		texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	#endif
	
	playerPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;
	
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
