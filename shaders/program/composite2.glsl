in_out vec2 texcoord;

flat in_out float distMultMult;

#if DEPTH_SUNRAYS_ENABLED == 1
	flat in_out vec2 lightCoord;
#endif
#ifdef VOL_CLOUDS_ENABLED
	flat in_out vec3 cloudsShadowcasterDir;
	flat in_out float cloudsCoverage;
#endif



#ifdef FSH

#include "/utils/projections.glsl"
#include "/utils/depth.glsl"
#include "/utils/borderFogAmount.glsl"

#include "/utils/getFogColor.glsl"
#if DEPTH_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_depth.glsl"
#endif
#if VOL_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_vol.glsl"
#endif
#ifdef VOL_CLOUDS_ENABLED
	#include "/lib/vol_clouds.glsl"
#endif
#if NETHER_CLOUDS_ENABLED == 1
	#include "/lib/nether_clouds.glsl"
#endif
#if END_CLOUDS_ENABLED == 1
	#include "/lib/end_clouds.glsl"
#endif

#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1 || defined VOL_CLOUDS_ENABLED || NETHER_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1
	#define NOISY_RENDERS_ACTIVE
#endif

void main() {
	bool isCloud = texelFetch(CLOUDS_TEXTURE, texelcoord * 2, 0).a > 0.0;
	
	#if FOG_IGNORES_TRANSPARENTS == 0
		float depth;
		if (isCloud) depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord * 2, 0).r;
		else depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord * 2, 0).r;
	#elif FOG_IGNORES_TRANSPARENTS == 1
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord * 2, 0).r;
	#endif
	vec3 viewPos = screenToView(vec3(texcoord, depth));
	#ifdef DISTANT_HORIZONS
		#if FOG_IGNORES_TRANSPARENTS == 0
			float depthDh;
			if (isCloud) depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord * 2, 0).r;
			else depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord * 2, 0).r;
		#elif FOG_IGNORES_TRANSPARENTS == 1
			float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord * 2, 0).r;
		#endif
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh));
		if (viewPosDh.z > viewPos.z) viewPos = viewPosDh;
	#endif
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	
	
	#if BORDER_FOG_ENABLED == 1 || CYLINDRICAL_CLIPPING == 1
		float _fogDistance;
		float fogAmount = getBorderFogAmount(playerPos, _fogDistance);
		#ifdef DISTANT_HORIZONS
			fogAmount = mix(fogAmount, 1.0, float(depth == 1.0 && depthDh == 1.0));
		#endif
		#ifdef VOXY
			fogAmount = mix(fogAmount, 1.0, float(depth == 1.0));
		#endif
	#else
		const float fogAmount = 0.0;
	#endif
	
	#ifdef OVERWORLD
		float distMult = max(playerPos.y + cameraPosition.y - 64.0, 0.0);
		const float distMultAmplitude = 1.5;
		const float distMultSlope = 16.0;
		distMult = distMultAmplitude * distMultSlope / (distMult + distMultSlope);
	#elif defined NETHER
		float distMult = max(playerPos.y + cameraPosition.y - 30.0, 0.0);
		const float distMultAmplitude = 3.0;
		const float distMultSlope = 6.0;
		distMult = distMultAmplitude * distMultSlope / (distMult + distMultSlope);
	#elif defined END
		const float distMult = 1.0;
	#endif
	
	
	
	#ifdef NOISY_RENDERS_ACTIVE
		vec3 pos = vec3(texcoord, depth);
		vec2 prevCoord = texcoord;
		if (!depthIsHand(depth)) {
			vec3 cameraOffset = cameraPosition - previousCameraPosition;
			prevCoord = reproject(pos, cameraOffset);
		}
		vec4 prevNoisyRender = vec4(0.0);
		bool prevIsValid = all(greaterThanEqual(prevCoord, vec2(0.0))) && all(lessThan(prevCoord, vec2(1.0)));
		if (prevIsValid) {
			float prevDepth = texture2D(PREV_DEPTH_TEXTURE, prevCoord).r;
			float depthDiff = (depth - prevDepth) / depth;
			prevIsValid = depthDiff < 0.00015;
		}
		if (prevIsValid) {
			ivec2 iPrevCoord = ivec2(prevCoord * viewSize) / 2;
			prevNoisyRender = texelFetch(NOISY_RENDERS_TEXTURE, iPrevCoord, 0);
		}
	#endif
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		float depthSunraysAddition = getDepthSunraysAmount();
		depthSunraysAddition *= 1.0 - 0.8 * fogAmount;
		float dither = bayer64(gl_FragCoord.xy);
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
		depthSunraysAddition += dither / 255.0;
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
	
	#ifdef VOL_CLOUDS_ENABLED
		vec2 cloudData = computeClouds(playerPos);
	#elif NETHER_CLOUDS_ENABLED == 1
		vec2 cloudData = computeNetherClouds(playerPos);
	#elif END_CLOUDS_ENABLED == 1
		vec2 cloudData = computeEndClouds(playerPos);
	#else
		vec2 cloudData = vec2(0.0);
	#endif
	
	
	
	// ======== TEMPORAL FILTERING FOR CLOUDS AND SUNRAYS ======== //
	
	#ifdef NOISY_RENDERS_ACTIVE
		if (prevIsValid) {
			#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
				vec2 prevSunraysDatas = prevNoisyRender.xy;
			#endif
			#if DEPTH_SUNRAYS_ENABLED == 1
				if (abs(prevSunraysDatas.x - depthSunraysAddition) > 0.02)
					depthSunraysAddition = mix(depthSunraysAddition, prevSunraysDatas.x, 0.7);
			#endif
			#if VOL_SUNRAYS_ENABLED == 1
				if (abs(prevSunraysDatas.y - volSunraysAmount) > 0.02)
					volSunraysAmount = mix(volSunraysAmount, prevSunraysDatas.y, 0.5);
			#endif
			#if defined VOL_CLOUDS_ENABLED || NETHER_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1
				vec2 prevCloudsData = prevNoisyRender.zw;
				cloudData = mix(cloudData, prevCloudsData, 0.75);
			#endif
		}
	#endif
	
	
	
	/* DRAWBUFFERS:6 */
	gl_FragData[0] = vec4(
		depthSunraysAddition,
		volSunraysAmount,
		cloudData
	);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	distMultMult = 1.0;
	distMultMult *= 1.0 - blindness;
	distMultMult *= 1.0 - darknessFactor;
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
		lightPos /= lightPos.z;
		lightCoord = lightPos.xy * 0.5 + 0.5;
	#endif
	
	
	
	// ======== CLOUDS ======== //
	
	#ifdef VOL_CLOUDS_ENABLED
		cloudsShadowcasterDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition) * 10.0;
		cloudsCoverage = mix(1.0 - CLOUD_COVERAGE, 0.8 - 0.6 * CLOUD_WEATHER_COVERAGE, rainStrength);
	#endif
	
	
	
}

#endif
