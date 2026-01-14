in_out vec2 texcoord;

#if DEPTH_SUNRAYS_ENABLED == 1
	flat in_out float depthSunraysAmountMult;
#endif
#if VOL_SUNRAYS_ENABLED == 1
	flat in_out float volSunraysAmountMult;
	flat in_out float volSunraysAmountMax;
#endif
#if NETHER_CLOUDS_ENABLED == 1
	flat in_out vec3 cloudsColor;
#endif



#ifdef FSH

#if VOL_SUNRAYS_ENABLED == 1
	#include "/utils/screen_to_view.glsl"
#endif
#if REALISTIC_CLOUDS_ENABLED == 1
	#include "/utils/getCloudColor.glsl"
#endif
#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	
	
	
	// ======== NOISY RENDERS ADDITION ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || REALISTIC_CLOUDS_ENABLED == 1 || NETHER_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1
		vec2 noisyRendersData      = texelFetch(NOISY_RENDERS_TEXTURE, texelcoord, 0).rg;
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
		vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
		#if BSL_MODE == 1
			depthSunraysColor = vec3(getLum(depthSunraysColor)) * 2.0;
		#endif
		sunraysDatas.x = 1.0 - (1.0 - sunraysDatas.x) * (1.0 - sunraysDatas.x);
		color += sunraysDatas.x * depthSunraysColor * depthSunraysAmountMult;
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR * 1.25 : SUNRAYS_MOON_COLOR * 1.25;
		float volSunraysAmount = sunraysDatas.y;
		volSunraysAmount = 1.0 / volSunraysAmount - 1.0;
		volSunraysAmount *= volSunraysAmountMult;
		
		vec3 screenPos = vec3(texcoord, texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r);
		vec3 viewPos = screenToView(screenPos);
		#ifdef DISTANT_HORIZONS
			vec3 screenPosDh = vec3(texcoord, texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r);
			vec3 viewPosDh = screenToViewDh(screenPosDh);
			if (viewPosDh.b > viewPos.b) viewPos = viewPosDh;
		#endif
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		float altitude = playerPos.y + cameraPosition.y;
		volSunraysAmount *= 1.0 - percentThrough(altitude, 64.0, 32.0);
		
		volSunraysAmount = exp(-volSunraysAmount); // after this, volSunraysAmount is inverted (1-x)
		volSunraysAmount = max(volSunraysAmount, volSunraysAmountMax);
		color *= 1.0 + (1.0 - volSunraysAmount) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
		color = mix(volSunraysColor, color, volSunraysAmount);
	#endif
	
	#if REALISTIC_CLOUDS_ENABLED == 1 || NETHER_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1
		vec2 cloudsData = unpack_2x8(noisyRendersData.y);
		cloudsData += unpack_2x8(noisyRendersDataUp.y   );
		cloudsData += unpack_2x8(noisyRendersDataDown.y );
		cloudsData += unpack_2x8(noisyRendersDataLeft.y );
		cloudsData += unpack_2x8(noisyRendersDataRight.y);
		cloudsData *= 0.2;
	#endif
	#if REALISTIC_CLOUDS_ENABLED == 1
		float thickness = 1.0 - cloudsData.x;
		float brightness = 1.0 - cloudsData.y;
		vec3 cloudColor = getCloudColor(0.6 + 0.4 * brightness);
		color = mix(color, cloudColor, thickness);
	#endif
	#if NETHER_CLOUDS_ENABLED == 1
		float thickness = 1.0 - cloudsData.x;
		float brightness = 1.0 - cloudsData.y;
		thickness *= 1.0 - (0.25 + 0.75 * NETHER_CLOUDS_TRANSPARENCY);
		color *= 1.0 - thickness;
		color += cloudsColor * brightness * thickness;
	#endif
	#if END_CLOUDS_ENABLED == 1
		float thickness = 1.0 - cloudsData.x;
		float brightness = cloudsData.y;
		thickness *= 0.6 - 0.5 * END_CLOUDS_TRANSPARENCY;
		color *= 1.0 - thickness;
		brightness = 1.0 - (1.0 - brightness) * (1.0 - brightness);
		color += mix(END_CLOUDS_DARK_COLOR, END_CLOUDS_BRIGHT_COLOR, brightness) * thickness;
	#endif
	
	
	
	// ======== BLOOM CALCULATIONS ======== //
	
	#if BLOOM_ENABLED == 1
		addBloom(color);
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
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		if (isSun) {
			depthSunraysAmountMult = (ambientSunPercent + ambientSunrisePercent + ambientSunsetPercent) * SUNRAYS_AMOUNT_DAY * 0.8;
			depthSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		} else {
			depthSunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT * 0.8;
		}
		depthSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		depthSunraysAmountMult *= 1.0 - 0.5 * inPaleGarden;
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		volSunraysAmountMult = sunAngle < 0.5 ? SUNRAYS_AMOUNT_DAY * 0.4 : SUNRAYS_AMOUNT_NIGHT * 0.4;
		volSunraysAmountMult *= sqrt(sunLightBrightness + moonLightBrightness);
		float eyeSkylightSmooth = eyeBrightnessSmooth.y / 240.0;
		volSunraysAmountMult *= mix(1.0, SUNRAYS_UNDERGROUND_MULT, (1.0 - eyeSkylightSmooth * eyeSkylightSmooth) * uint(sunAngle < 0.5));
		volSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		volSunraysAmountMult *= 1.0 - 0.5 * inPaleGarden;
		volSunraysAmountMax = 0.4 * (sunAngle < 0.5 ? SUNRAYS_AMOUNT_MAX_DAY : SUNRAYS_AMOUNT_MAX_NIGHT); 
		volSunraysAmountMax *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		volSunraysAmountMax = 1.0 - volSunraysAmountMax;
	#endif
	#if NETHER_CLOUDS_ENABLED == 1
		cloudsColor = normalize(fogColor) * NETHER_CLOUDS_FOG_INFLUENCE + NETHER_CLOUDS_BASE_COLOR;
	#endif
	
	
	
}

#endif
