#ifdef FIRST_PASS
	in_out vec2 texcoord;
	
	flat in_out vec3 atmoFogColor;
	flat in_out float fogDensity;
	flat in_out float fogMult;
	flat in_out float fogDarken;
	flat in_out float extraFogDist;
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		flat in_out vec2 lightCoord;
		flat in_out float depthSunraysAmountMult;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		flat in_out float volSunraysAmountMult;
		flat in_out float volSunraysAmountMax;
	#endif
	#if REALISTIC_CLOUDS_ENABLED == 1
		flat in_out vec3 cloudsShadowcasterDir;
		flat in_out float cloudsCoverage;
	#endif
	
#endif



#ifdef FSH

#include "/utils/screen_to_view.glsl"
#include "/lib/borderFogAmount.glsl"
#include "/utils/reprojection.glsl"

#include "/utils/getSkyColor.glsl"
#if DEPTH_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_depth.glsl"
#endif
#if VOL_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_vol.glsl"
#endif
#if REALISTIC_CLOUDS_ENABLED == 1
	#include "/lib/clouds.glsl"
#endif

#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || (REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD)
	#define NOISY_RENDERS_ACTIVE
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	bool isCloud = unpack_2x8(texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0).y).y > 0.5;
	
	float depth;
	if (isCloud) depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	else depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float depthDh;
		if (isCloud) depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		else depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh)  ARGS_IN);
		if (viewPosDh.z > viewPos.z) viewPos = viewPosDh;
	#endif
	
	#include "/import/gbufferModelViewInverse.glsl"
	#ifdef DISTANT_HORIZONS
		float fogAmount = float(depth == 1.0 && depthDh == 1.0);
	#else
		float fogAmount = getBorderFogAmount(transform(gbufferModelViewInverse, viewPos)  ARGS_IN);
	#endif
	
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	vec3 playerPosForFog = playerPos;
	playerPos.y *= 0.02;
	float distMult = playerPos.y < 0.0 ? sqrt(1.0 - playerPos.y) : 1.0 / (playerPos.y * 0.5 + 1.0);
	playerPos.y /= 0.02;
	
	
	
	#ifdef NOISY_RENDERS_ACTIVE
		vec3 pos = vec3(texcoord, min(depth, 0.99995));
		vec2 prevCoord = texcoord;
		if (!depthIsHand(depth)) {
			#include "/import/cameraPosition.glsl"
			#include "/import/previousCameraPosition.glsl"
			vec3 cameraOffset = cameraPosition - previousCameraPosition;
			prevCoord = reprojection(pos, cameraOffset  ARGS_IN);
		}
		vec2 prevNoisyRender;
		bool prevIsValid = prevCoord == clamp(prevCoord, 0.0, 1.0);
		ivec2 iPrevCoord = ivec2(prevCoord * viewSize);
		if (prevIsValid) {
			float prevDepth;
			if (isCloud) prevDepth = texelFetch(DEPTH_BUFFER_WO_TRANS, iPrevCoord, 0).r;
			else prevDepth = texelFetch(DEPTH_BUFFER_ALL, iPrevCoord, 0).r;
			prevIsValid = prevDepth - 0.0001 <= depth;
		}
		if (prevIsValid) {
			#include "/import/viewSize.glsl"
			prevNoisyRender = texelFetch(NOISY_RENDERS_TEXTURE, iPrevCoord, 0).rg;
		}
	#endif
	
	
	
	// ======== AUTO EXPOSURE ======== //
	
	#include "/import/eyeBrightnessSmooth.glsl"
	vec2 brightnesses = eyeBrightnessSmooth / 240.0;
	#if AUTO_EXPOSURE_ENABLED == 1
		vec2 normalizedBrightnesses = brightnesses;
		#ifdef NETHER
			normalizedBrightnesses.y = 0.5;
		#elif defined END
			normalizedBrightnesses.y = 1.0;
		#endif
		normalizedBrightnesses *= vec2(0.5, 1.0); // weights
		float autoExposureAmount = max(normalizedBrightnesses.x, normalizedBrightnesses.y);
		float autoExposureMult = mix(AUTO_EXPOSURE_DARK_MULT, AUTO_EXPOSURE_BRIGHT_MULT, autoExposureAmount);
		autoExposureMult = mix(autoExposureMult, 1.0, fogAmount);
		color *= autoExposureMult;
	#endif
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	float fogDist = length(playerPosForFog);
	fogDist *= distMult;
	
	vec3 atmoFogColor = atmoFogColor;
	float fogDensity = fogDensity;
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		atmoFogColor = getSkyColor(normalize(viewPos)  ARGS_IN);
		#include "/import/blindness.glsl"
		atmoFogColor *= 1.0 - blindness;
		#include "/import/darknessFactor.glsl"
		atmoFogColor *= 1.0 - darknessFactor;
		#ifdef OVERWORLD
			fogDensity = mix(UNDERGROUND_FOG_DENSITY, ATMOSPHERIC_FOG_DENSITY, min(brightnesses.y * 1.5, 1.0));
			#include "/import/betterRainStrength.glsl"
			fogDensity = mix(fogDensity, WEATHER_FOG_DENSITY, betterRainStrength);
			#include "/import/dayPercent.glsl"
			#include "/import/inPaleGarden.glsl"
			fogDensity = mix(fogDensity, mix(PALE_GARDEN_FOG_NIGHT_DENSITY, PALE_GARDEN_FOG_DENSITY, dayPercent), inPaleGarden);
		#elif defined NETHER
			fogDensity = NETHER_FOG_DENSITY;
		#elif defined END
			fogDensity = END_FOG_DENSITY;
		#endif
		fogDensity = mix(fogDensity, BLINDNESS_EFFECT_FOG_DENSITY, blindness);
		fogDensity = mix(fogDensity, DARKNESS_EFFECT_FOG_DENSITY / 2.0, darknessFactor);
		fogDensity /= 300.0;
	}
	
	float atmoFogAmount = 1.0 - exp(-fogDensity * (fogDist + extraFogDist));
	atmoFogAmount *= 1.0 - fogAmount;
	atmoFogAmount *= fogMult;
	color *= 1.0 - atmoFogAmount * fogDarken;
	color += atmoFogColor * atmoFogAmount * (0.5 + 0.5 * brightnesses.y);
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		float depthSunraysAddition = getDepthSunraysAmount(ARG_IN) * depthSunraysAmountMult;
		depthSunraysAddition *= 1.0 - fogAmount;
	#else
		float depthSunraysAddition = 0.0;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		float rawVolSunraysAmount = getVolSunraysAmount(playerPosForFog, distMult  ARGS_IN);
		rawVolSunraysAmount *= 1.0 - fogAmount;
		float volSunraysAmount = exp(-rawVolSunraysAmount);
		volSunraysAmount = max(volSunraysAmount, volSunraysAmountMax); // at this point, the amount is inverted (1-x)
	#else
		float volSunraysAmount = 1.0;
	#endif
	
	
	
	// ======== CLOUDS RENDERING ======== //
	
	#if REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD
		vec2 cloudData = computeClouds(playerPos ARGS_IN);
	#else
		vec2 cloudData = vec2(0.0);
	#endif
	
	
	
	// ======== TEMPORAL FILTERING FOR CLOUDS AND SUNRAYS ======== //
	
	#ifdef NOISY_RENDERS_ACTIVE
		if (prevIsValid) {
			#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
				vec2 prevSunraysDatas = unpack_2x8(prevNoisyRender.x);
			#endif
			#if DEPTH_SUNRAYS_ENABLED == 1
				depthSunraysAddition = mix(prevSunraysDatas.x, depthSunraysAddition, 0.25);
			#endif
			#if VOL_SUNRAYS_ENABLED == 1
				volSunraysAmount = mix(prevSunraysDatas.y, volSunraysAmount, 0.25);
			#endif
			#if REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD
				cloudData = mix(unpack_2x8(prevNoisyRender.y), cloudData, 0.35);
			#endif
		}
	#endif
	
	
	
	// ======== BLOOM FILTERING ======== //
	
	#if BLOOM_ENABLED == 1
		float bloomMult = dot(color, vec3(1.0, 0.8, 0.0) * 0.5);
		bloomMult = (bloomMult - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		bloomMult = clamp(bloomMult, 0.0, 1.0) * (1.0 - fogAmount);
		bloomMult *= bloomMult;
		vec3 bloomColor = color * bloomMult;
	#endif
	
	
	
	#if BLOOM_ENABLED == 0 && !defined NOISY_RENDERS_ACTIVE
		/* DRAWBUFFERS:0 */
		color *= 0.5;
		gl_FragData[0] = vec4(color, 1.0);
	#endif
	#if BLOOM_ENABLED == 1 && !defined NOISY_RENDERS_ACTIVE
		/* DRAWBUFFERS:04 */
		color *= 0.5;
		bloomColor *= 0.5;
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
	#if BLOOM_ENABLED == 0 && defined NOISY_RENDERS_ACTIVE
		/* DRAWBUFFERS:06 */
		color *= 0.5;
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(
			pack_2x8(depthSunraysAddition, volSunraysAmount),
			pack_2x8(cloudData),
			0.0, 1.0
		);
	#endif
	#if BLOOM_ENABLED == 1 && defined NOISY_RENDERS_ACTIVE
		/* DRAWBUFFERS:046 */
		color *= 0.5;
		bloomColor *= 0.5;
		gl_FragData[0] = vec4(color, 1.0);
		gl_FragData[1] = vec4(bloomColor, 1.0);
		gl_FragData[2] = vec4(
			pack_2x8(depthSunraysAddition, volSunraysAmount),
			pack_2x8(cloudData),
			0.0, 1.0
		);
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	

	// ======== ATMOSPHERIC FOG ======== //
	
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		#include "/import/inPaleGarden.glsl"
		#ifdef OVERWORLD
			fogMult = 0.75 + 0.25 * inPaleGarden;
			fogDarken = 0.5;
		#else
			fogMult = 1.0;
			fogDarken = 1.0;
		#endif
		extraFogDist = 1.0 * inPaleGarden;
	} else if (isEyeInWater == 1) {
		atmoFogColor = IN_WATER_COLOR;
		fogDensity = 0.03;
		fogMult = 1.0;
		fogDarken = 1.0;
		extraFogDist = 16.0;
	} else if (isEyeInWater == 2) {
		atmoFogColor = IN_LAVA_COLOR;
		fogDensity = 10.0;
		fogMult = 0.75;
		fogDarken = 0.5;
		extraFogDist = 0.0;
	} else if (isEyeInWater == 3) {
		atmoFogColor = IN_POWDERED_SNOW_COLOR;
		fogDensity = 10.0;
		fogMult = 0.75;
		fogDarken = 0.5;
		extraFogDist = 0.0;
	}
	
	#include "/import/blindness.glsl"
	atmoFogColor *= 1.0 - blindness;
	fogDensity = mix(fogDensity, BLINDNESS_EFFECT_FOG_DENSITY / 300.0, blindness);
	fogMult = mix(fogMult, 1.0, blindness);
	fogDarken = mix(fogDarken, 1.0, blindness);
	extraFogDist *= 1.0 - blindness;
	
	#include "/import/darknessFactor.glsl"
	atmoFogColor *= 1.0 - darknessFactor;
	fogDensity = mix(fogDensity, DARKNESS_EFFECT_FOG_DENSITY / 600.0, darknessFactor);
	fogMult = mix(fogMult, 1.0, darknessFactor);
	fogDarken = mix(fogDarken, 1.0, darknessFactor);
	extraFogDist = mix(extraFogDist, 4.0, darknessFactor);
	
	
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		#include "/import/ambientSunPercent.glsl"
		#include "/import/ambientMoonPercent.glsl"
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
		#include "/import/inPaleGarden.glsl"
	#endif
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || REALISTIC_CLOUDS_ENABLED == 1
		#include "/import/rainStrength.glsl"
	#endif
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || REALISTIC_CLOUDS_ENABLED == 1
		#include "/import/shadowLightPosition.glsl"
	#endif
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		
		#include "/import/gbufferProjection.glsl"
		vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
		lightPos /= lightPos.z;
		lightCoord = lightPos.xy * 0.5 + 0.5;
		
		#include "/import/isSun.glsl"
		if (isSun) {
			depthSunraysAmountMult = (ambientSunPercent + ambientSunrisePercent + ambientSunsetPercent) * SUNRAYS_AMOUNT_DAY * 0.5;
			depthSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		} else {
			depthSunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT * 0.5;
		}
		depthSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		depthSunraysAmountMult *= 1.0 - 0.5 * inPaleGarden;
		
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		#include "/import/sunLightBrightness.glsl"
		#include "/import/moonLightBrightness.glsl"
		#include "/import/sunAngle.glsl"
		volSunraysAmountMult = sunAngle < 0.5 ? SUNRAYS_AMOUNT_DAY * 0.2 : SUNRAYS_AMOUNT_NIGHT * 0.2;
		volSunraysAmountMult *= sqrt(sunLightBrightness + moonLightBrightness);
		volSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		volSunraysAmountMult *= 1.0 - 0.5 * inPaleGarden;
		volSunraysAmountMax = 0.4 * (sunAngle < 0.5 ? SUNRAYS_AMOUNT_MAX_DAY : SUNRAYS_AMOUNT_MAX_NIGHT); 
		volSunraysAmountMax *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		volSunraysAmountMax = 1.0 - volSunraysAmountMax;
	#endif
	
	
	
	// ======== CLOUDS ======== //
	
	#if REALISTIC_CLOUDS_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		cloudsShadowcasterDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition) * 10.0;
		cloudsCoverage = mix(1.0 - CLOUD_COVERAGE, 0.8 - 0.6 * CLOUD_WEATHER_COVERAGE, rainStrength);
	#endif
	
	
	
}

#endif
