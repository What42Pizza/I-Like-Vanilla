#if CLOUD_COMPATIBILITY == 1
	in_out vec2 texcoord;
#endif
in_out vec3 playerPos;
#if STORY_MODE_CLOUDS_ENABLED == 1
	in_out float alphaMult;
#endif



#ifdef FSH

#include "/utils/getCloudColor.glsl"

#ifdef DISTANT_HORIZONS
	#include "/utils/depth.glsl"
#endif

void main() {
	
	#if CLOUD_COMPATIBILITY == 1
		vec4 color = texture2D(MAIN_TEXTURE, texcoord);
		if (color.a < 0.5) discard;
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
	
	
	// story mode clouds
	#if STORY_MODE_CLOUDS_ENABLED == 1
		float alphaMult = 1.0 - alphaMult;
		#if STORY_MODE_CLOUDS_CURVE == 2
			alphaMult = pow2(alphaMult);
		#elif STORY_MODE_CLOUDS_CURVE == 3
			alphaMult = pow3(alphaMult);
		#elif STORY_MODE_CLOUDS_CURVE == 4
			alphaMult = pow4(alphaMult);
		#elif STORY_MODE_CLOUDS_CURVE == 5
			alphaMult = pow5(alphaMult);
		#endif
		color.a *= 1.0 - alphaMult;
	#endif
	
	
	// cloud color
	vec3 xDir = dFdx(playerPos);
	vec3 yDir = dFdy(playerPos);
	vec3 normal = normalize(cross(xDir, yDir));
	normal.xz = abs(normal.xz);
	float cloudBrightness = dot(normal, normalize(vec3(0.5, 1.0, 0.0)));
	float maxBrightnessDecrease = mix(0.25, 0.1, betterRainStrength);
	color.rgb *= getCloudColor(cloudBrightness * maxBrightnessDecrease + (1.0 - maxBrightnessDecrease));
	
	
	// fog transparency
	float dist = length(playerPos.xz) / VANILLA_CLOUDS_SCALE_XZ;
	dist /= 128.0 * 16.0 * 1.25;
	float fogAmount = percentThrough(dist, 1.0, CLOUD_FOG_START);
	#if CLOUD_FOG_CURVE == 2
		fogAmount = pow2(fogAmount);
	#elif CLOUD_FOG_CURVE == 3
		fogAmount = pow3(fogAmount);
	#elif CLOUD_FOG_CURVE == 4
		fogAmount = pow4(fogAmount);
	#elif CLOUD_FOG_CURVE == 5
		fogAmount = pow5(fogAmount);
	#endif
	color.a *= fogAmount;
	
	/* DRAWBUFFERS:03 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.0, 1.0, 1.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(0.0, 0.25),
		pack_7_7_1_1(0.0, 0.0, 1.0, 0.0),
		0.0, 1.0
	);
	
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	#if CLOUD_COMPATIBILITY == 1
		texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	#endif
	
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	#if STORY_MODE_CLOUDS_ENABLED == 1
		alphaMult = percentThrough(cameraPosition.y, cloudHeight + 8.0, cloudHeight - 4.0); // start off inverted
		alphaMult *= float(playerPos.y + cameraPosition.y > cloudHeight + 1.5);
		alphaMult = 1.0 - alphaMult;
	#endif
	playerPos.xz *= VANILLA_CLOUDS_SCALE_XZ;
	playerPos.y *= VANILLA_CLOUDS_SCALE_Y;
	playerPos.y += VANILLA_CLOUDS_HEIGHT_OFFSET;
	viewPos = transform(gbufferModelView, playerPos);
	
	gl_Position = viewToNdc(viewPos);
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
}

#endif
