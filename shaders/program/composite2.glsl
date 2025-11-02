#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if REALISTIC_CLOUDS_ENABLED == 1
	#include "/utils/getCloudColor.glsl"
#endif
#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	
	
	
	// ======== NOISY RENDERS ADDITION ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || (REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD)
		vec2 noisyRendersData      = texelFetch(NOISY_RENDERS_TEXTURE, texelcoord, 0).rg;
		#include "/import/viewWidth.glsl"
		#include "/import/viewHeight.glsl"
		vec2 noisyRendersDataUp    = texelFetch(NOISY_RENDERS_TEXTURE, clamp(texelcoord + ivec2( 0,  1), ivec2(0), ivec2(viewWidth, viewHeight) - 1), 0).rg;
		vec2 noisyRendersDataDown  = texelFetch(NOISY_RENDERS_TEXTURE, clamp(texelcoord + ivec2( 0, -1), ivec2(0), ivec2(viewWidth, viewHeight) - 1), 0).rg;
		vec2 noisyRendersDataLeft  = texelFetch(NOISY_RENDERS_TEXTURE, clamp(texelcoord + ivec2(-1,  0), ivec2(0), ivec2(viewWidth, viewHeight) - 1), 0).rg;
		vec2 noisyRendersDataRight = texelFetch(NOISY_RENDERS_TEXTURE, clamp(texelcoord + ivec2( 1,  0), ivec2(0), ivec2(viewWidth, viewHeight) - 1), 0).rg;
	#endif
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		vec2 sunraysDatas = unpack_2x8(noisyRendersData.x);
		sunraysDatas += unpack_2x8(noisyRendersDataUp.x   );
		sunraysDatas += unpack_2x8(noisyRendersDataDown.x );
		sunraysDatas += unpack_2x8(noisyRendersDataLeft.x );
		sunraysDatas += unpack_2x8(noisyRendersDataRight.x);
		sunraysDatas *= 0.2;
	#endif
	#if DEPTH_SUNRAYS_ENABLED == 1
		#include "/import/isSun.glsl"
		vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
		color += sunraysDatas.x * depthSunraysColor;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		#include "/import/sunAngle.glsl"
		vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR * 1.25 : SUNRAYS_MOON_COLOR * 1.25;
		color *= 1.0 + (1.0 - sunraysDatas.y) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
		color = mix(volSunraysColor, color, sunraysDatas.y);
	#endif
	#if REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD
		vec2 cloudsData = unpack_2x8(noisyRendersData.y);
		cloudsData += unpack_2x8(noisyRendersDataUp.y   );
		cloudsData += unpack_2x8(noisyRendersDataDown.y );
		cloudsData += unpack_2x8(noisyRendersDataLeft.y );
		cloudsData += unpack_2x8(noisyRendersDataRight.y);
		cloudsData *= 0.2;
		float thickness = 1.0 - cloudsData.x;
		float brightness = 1.0 - cloudsData.y;
		vec3 cloudColor = getCloudColor(0.25 + 0.75 * brightness  ARGS_IN);
		color = mix(color, cloudColor, thickness * 0.5);
	#endif

	
	
	// ======== BLOOM CALCULATIONS ======== //
	
	#if BLOOM_ENABLED == 1
		addBloom(color  ARGS_IN);
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
