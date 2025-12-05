in_out vec2 texcoord;

flat in_out vec3 atmoFogColor;
flat in_out float fogDensity;
flat in_out float fogMult;
flat in_out float fogDarken;
flat in_out float extraFogDist;

#if DEPTH_SUNRAYS_ENABLED == 1
	flat in_out vec2 lightCoord;
#endif
#if REALISTIC_CLOUDS_ENABLED == 1
	flat in_out vec3 cloudsShadowcasterDir;
	flat in_out float cloudsCoverage;
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
#if NETHER_CLOUDS_ENABLED == 1
	#include "/lib/nether_clouds.glsl"
#endif

#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || REALISTIC_CLOUDS_ENABLED == 1 || NETHER_CLOUDS_ENABLED == 1
	#define NOISY_RENDERS_ACTIVE
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	bool isCloud = unpack_2x8(texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0).y).y > 0.5;
	
	float depth;
	if (isCloud) depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	else depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth));
	#ifdef DISTANT_HORIZONS
		float depthDh;
		if (isCloud) depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		else depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh));
		if (viewPosDh.z > viewPos.z) viewPos = viewPosDh;
	#endif
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	
	#ifdef DISTANT_HORIZONS
		float fogAmount = float(depth == 1.0 && depthDh == 1.0);
	#else
		float fogAmount = getBorderFogAmount(playerPos);
	#endif
	
	vec3 playerPosForFog = playerPos;
	#ifndef NETHER
		const float yMult = 0.02;
	#endif
	#ifdef NETHER
		const float yMult = 0.05;
	#endif
	float distMult= playerPos.y * yMult;
	distMult = distMult < 0.0 ? sqrt(1.0 - distMult) : 1.0 / (distMult * 0.5 + 1.0);
	
	
	
	#ifdef NOISY_RENDERS_ACTIVE
		vec3 pos = vec3(texcoord, depth);
		vec2 prevCoord = texcoord;
		if (!depthIsHand(depth)) {
			vec3 cameraOffset = cameraPosition - previousCameraPosition;
			prevCoord = reprojection(pos, cameraOffset);
		}
		vec2 prevNoisyRender;
		bool prevIsValid = all(greaterThanEqual(prevCoord, vec2(0.0))) && all(lessThan(prevCoord, vec2(1.0)));
		if (prevIsValid) {
			float prevDepth = texture2D(PREV_DEPTH_TEXTURE, prevCoord).r;
			float depthDiff = (depth - prevDepth) / depth;
			prevIsValid = depthDiff < 0.00015;
		}
		if (prevIsValid) {
			ivec2 iPrevCoord = ivec2(prevCoord * viewSize);
			prevNoisyRender = texelFetch(NOISY_RENDERS_TEXTURE, iPrevCoord, 0).rg;
		}
	#endif
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	vec2 brightnesses = eyeBrightnessSmooth / 240.0;
	float fogDist = length(playerPos);
	fogDist *= distMult;
	
	vec3 atmoFogColor = atmoFogColor;
	float fogDensity = fogDensity;
	if (isEyeInWater == 0) {
		atmoFogColor = getSkyColor(normalize(viewPos), false);
		atmoFogColor *= 1.0 - blindness;
		atmoFogColor *= 1.0 - darknessFactor;
		#ifdef OVERWORLD
			fogDensity = mix(UNDERGROUND_FOG_DENSITY, ATMOSPHERIC_FOG_DENSITY, min(brightnesses.y * 1.5, 1.0));
			fogDensity = mix(fogDensity, WEATHER_FOG_DENSITY, betterRainStrength);
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
		float depthSunraysAddition = getDepthSunraysAmount();
		depthSunraysAddition *= 1.0 - 0.8 * fogAmount;
	#else
		float depthSunraysAddition = 0.0;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		float volSunraysAmount = getVolSunraysAmount(playerPos, distMult);
		volSunraysAmount *= 1.0 - fogAmount;
		volSunraysAmount = 1.0 / (1.0 + volSunraysAmount * 0.01); // compress data to [0-1] (the *0.01 is pretty important for preventing quantization, if the strength needs to be changed, do so elsewhere)
	#else
		float volSunraysAmount = 1.0;
	#endif
	
	
	
	// ======== CLOUDS RENDERING ======== //
	
	#if REALISTIC_CLOUDS_ENABLED == 1
		vec2 cloudData = computeClouds(playerPos);
	#elif NETHER_CLOUDS_ENABLED == 1
		vec2 cloudData = computeNetherClouds(playerPos);
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
				if (abs(prevSunraysDatas.x - depthSunraysAddition) > 0.02)
					depthSunraysAddition = mix(prevSunraysDatas.x, depthSunraysAddition, 0.25);
			#endif
			#if VOL_SUNRAYS_ENABLED == 1
				if (abs(prevSunraysDatas.y - volSunraysAmount) > 0.02)
					volSunraysAmount = mix(prevSunraysDatas.y, volSunraysAmount, 0.5);
			#endif
			#if REALISTIC_CLOUDS_ENABLED == 1 || NETHER_CLOUDS_ENABLED == 1
				vec2 prevCloudsData = unpack_2x8(prevNoisyRender.y);
				cloudData = mix(prevCloudsData, cloudData, 0.5);
			#endif
		}
	#endif
	
	
	
	// ======== BLOOM FILTERING ======== //
	
	#if BLOOM_ENABLED == 1
		float bloomMult = dot(color, vec3(1.0, 0.8, 0.0) * 0.5);
		bloomMult = (bloomMult - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		bloomMult = clamp(bloomMult, 0.0, 1.0) * (1.0 - fogAmount);
		bloomMult *= 0.75 + 0.25 * getSaturation(color);
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
	
	if (isEyeInWater == 0) {
		#ifdef OVERWORLD
			fogMult = 0.75 + 0.25 * inPaleGarden;
			fogDarken = 0.5;
		#else
			fogMult = 1.0;
			fogDarken = 1.0;
		#endif
		extraFogDist = 1.0 * inPaleGarden;
		extraFogDist += betterRainStrength * 8.0;
	} else if (isEyeInWater == 1) {
		atmoFogColor = WATER_FOG_COLOR;
		fogDensity = WATER_FOG_DENSITY * 0.25;
		fogMult = 1.0;
		fogDarken = 1.0;
		extraFogDist = 16.0;
	} else if (isEyeInWater == 2) {
		atmoFogColor = LAVA_FOG_COLOR;
		fogDensity = LAVA_FOG_DENSITY * 0.25;
		fogMult = 1.0;
		fogDarken = 1.0;
		extraFogDist = 1.5;
	} else if (isEyeInWater == 3) {
		atmoFogColor = POWDERED_SNOW_FOG_COLOR;
		fogDensity = POWDERED_SNOW_FOG_DENSITY * 0.25;
		fogMult = 1.0;
		fogDarken = 1.0;
		extraFogDist = 1.0;
	}
	
	atmoFogColor *= 1.0 - blindness;
	fogDensity = mix(fogDensity, BLINDNESS_EFFECT_FOG_DENSITY / 300.0, blindness);
	fogMult = mix(fogMult, 1.0, blindness);
	fogDarken = mix(fogDarken, 1.0, blindness);
	extraFogDist *= 1.0 - blindness;
	
	atmoFogColor *= 1.0 - darknessFactor;
	fogDensity = mix(fogDensity, DARKNESS_EFFECT_FOG_DENSITY / 600.0, darknessFactor);
	fogMult = mix(fogMult, 1.0, darknessFactor);
	fogDarken = mix(fogDarken, 1.0, darknessFactor);
	extraFogDist = mix(extraFogDist, 4.0, darknessFactor);
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
		lightPos /= lightPos.z;
		lightCoord = lightPos.xy * 0.5 + 0.5;
	#endif
	
	
	
	// ======== CLOUDS ======== //
	
	#if REALISTIC_CLOUDS_ENABLED == 1
		cloudsShadowcasterDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition) * 10.0;
		cloudsCoverage = mix(1.0 - CLOUD_COVERAGE, 0.8 - 0.6 * CLOUD_WEATHER_COVERAGE, rainStrength);
	#endif
	
	
	
}

#endif
