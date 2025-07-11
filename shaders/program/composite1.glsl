#ifdef FIRST_PASS
	in_out vec2 texcoord;
	
	#if DEPTH_SUNRAYS_ENABLED == 1
		flat in_out vec2 lightCoord;
		flat in_out float depthSunraysAmountMult;
	#endif
	#if VOL_SUNRAYS_ENABLED == 1
		flat in_out float volSunraysAmountMult;
		flat in_out float volSunraysAmountMax;
	#endif
#endif



#ifdef FSH

#include "/utils/screen_to_view.glsl"
#include "/lib/borderFog/getBorderFogAmount.glsl"

#include "/utils/getSkyColor.glsl"
#if DEPTH_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_depth.glsl"
#endif
#if VOL_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_vol.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	bool isCloud = unpackVec2(texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0).z).y > 0.5;
	
	float depth;
	if (isCloud) depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	else depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float depthDh;
		if (isCloud) depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		else depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh)  ARGS_IN);
		if (dot(viewPosDh, viewPosDh) < dot(viewPos, viewPos)) viewPos = viewPosDh;
	#endif
	
	#include "/import/gbufferModelViewInverse.glsl"
	#ifdef DISTANT_HORIZONS
		float fogAmount = float(depth == 1.0 && depthDh == 1.0);
	#else
		float fogAmount = getBorderFogAmount(transform(gbufferModelViewInverse, viewPos)  ARGS_IN);
	#endif
	if (isCloud) fogAmount = min(fogAmount, 0.6);
	
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	playerPos.y *= 0.02;
	float distMult = playerPos.y < 0.0 ? sqrt(1.0 - playerPos.y) : 1.0 / (playerPos.y * 0.5 + 1.0);
	playerPos.y /= 0.02;
	
	
	
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
	
	float fogDist = length(viewPos);
	fogDist *= distMult;
	vec3 fogColor;
	float fogSlope;
	float fogMult;
	float fogDarken;
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		fogColor = getSkyColor(normalize(viewPos), false  ARGS_IN);
		#ifdef OVERWORLD
			float density = mix(UNDERGROUND_FOG_DENSITY, ATMOSPHERIC_FOG_DENSITY, brightnesses.y);
		#elif defined NETHER
			float density = NETHER_FOG_DENSITY;
		#elif defined END
			float density = END_FOG_DENSITY;
		#endif
		#include "/import/betterRainStrength.glsl"
		density = mix(density, WEATHER_FOG_DENSITY, betterRainStrength);
		fogSlope = 300.0 / (density + 0.00001);
		#ifdef OVERWORLD
			fogMult = 0.75;
			fogDarken = 0.5;
		#else
			fogMult = 1.0;
			fogDarken = 1.0;
		#endif
	} else if (isEyeInWater == 1) {
		fogColor = IN_WATER_COLOR;
		fogSlope = 7.0;
		fogDist += 6.0;
		fogMult = 1.0;
		fogDarken = 1.0;
	} else if (isEyeInWater == 2) {
		fogColor = IN_LAVA_COLOR;
		fogSlope = 0.1;
		fogMult = 0.75;
		fogDarken = 0.5;
	} else if (isEyeInWater == 3) {
		fogColor = IN_POWDERED_SNOW_COLOR;
		fogSlope = 0.1;
		fogMult = 0.75;
		fogDarken = 0.5;
	}
	float atmoFogAmount = 1.0 - fogSlope / (fogSlope + fogDist);
	atmoFogAmount *= 1.0 - fogAmount;
	atmoFogAmount *= fogMult;
	color *= 1.0 - atmoFogAmount * fogDarken;
	color += fogColor * atmoFogAmount * (0.5 + 0.5 * brightnesses.y);
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		
		#if DEPTH_SUNRAYS_ENABLED == 1
			#include "/import/isSun.glsl"
			vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			vec3 depthSunraysAddition = getDepthSunraysAmount(ARG_IN) * depthSunraysAmountMult * depthSunraysColor;
			depthSunraysAddition *= 1.0 - fogAmount;
			color += depthSunraysAddition;
		#endif
		#if VOL_SUNRAYS_ENABLED == 1
			#include "/import/sunAngle.glsl"
			vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR * 1.25 : SUNRAYS_MOON_COLOR * 1.25;
			float rawVolSunraysAmount = getVolSunraysAmount(playerPos, distMult  ARGS_IN) * volSunraysAmountMult;
			rawVolSunraysAmount *= 1.0 - fogAmount;
			float volSunraysAmount = 1.0 / (rawVolSunraysAmount + 1.0);
			color *= 1.0 + (1.0 - volSunraysAmount) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
			color = mix(volSunraysColor, color, max(volSunraysAmount, volSunraysAmountMax));
		#endif
		
	#endif
	
	
	
	// ======== BLOOM FILTERING ======== //
	
	#if BLOOM_ENABLED == 1
		float bloomMult = getColorLum(color * vec3(2.0, 1.0, 0.4));
		bloomMult = (bloomMult - BLOOM_LOW_CUTOFF) / (BLOOM_HIGH_CUTOFF - BLOOM_LOW_CUTOFF);
		bloomMult = clamp(bloomMult, 0.0, 1.0) * (1.0 - fogAmount);
		bloomMult = sqrt(bloomMult);
		vec3 bloomColor = color * bloomMult;
	#endif
	
	
	
	/* DRAWBUFFERS:1 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:15 */
		bloomColor *= 0.5;
		gl_FragData[1] = vec4(bloomColor, 1.0);
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		#include "/import/ambientSunPercent.glsl"
		#include "/import/ambientMoonPercent.glsl"
		#include "/import/ambientSunrisePercent.glsl"
		#include "/import/ambientSunsetPercent.glsl"
	#endif
	
	#if DEPTH_SUNRAYS_ENABLED == 1
	
		#include "/import/shadowLightPosition.glsl"
		#include "/import/gbufferProjection.glsl"
		vec3 lightPos = shadowLightPosition * mat3(gbufferProjection);
		lightPos /= lightPos.z;
		lightCoord = lightPos.xy * 0.5 + 0.5;
		
		#include "/import/isSun.glsl"
		if (isSun) {
			depthSunraysAmountMult = (ambientSunPercent + ambientSunrisePercent + ambientSunsetPercent) * SUNRAYS_AMOUNT_DAY;
			depthSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		} else {
			depthSunraysAmountMult = (ambientMoonPercent + (ambientSunrisePercent + ambientSunsetPercent) * 0.5) * SUNRAYS_AMOUNT_NIGHT;
		}
		#include "/import/rainStrength.glsl"
		depthSunraysAmountMult *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		
	#endif
	
	#if VOL_SUNRAYS_ENABLED == 1
		#include "/import/sunLightBrightness.glsl"
		#include "/import/moonLightBrightness.glsl"
		#include "/import/sunAngle.glsl"
		volSunraysAmountMult = sunAngle < 0.5 ? SUNRAYS_AMOUNT_DAY : SUNRAYS_AMOUNT_NIGHT;
		volSunraysAmountMult *= sqrt(sunLightBrightness + moonLightBrightness);
		volSunraysAmountMult *= 1.0 + ambientSunrisePercent * SUNRAYS_INCREASE_SUNRISE + ambientSunsetPercent * SUNRAYS_INCREASE_SUNSET;
		volSunraysAmountMax = 0.4 * (sunAngle < 0.5 ? SUNRAYS_AMOUNT_MAX_DAY : SUNRAYS_AMOUNT_MAX_NIGHT);
		#include "/import/rainStrength.glsl"
		volSunraysAmountMax *= 1.0 - rainStrength * (1.0 - SUNRAYS_WEATHER_MULT);
		volSunraysAmountMax = 1.0 - volSunraysAmountMax;
	#endif
	
}

#endif
