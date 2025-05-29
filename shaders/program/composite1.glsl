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
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb;
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh)  ARGS_IN);
		if (dot(viewPosDh, viewPosDh) < dot(viewPos, viewPos)) viewPos = viewPosDh;
	#endif
	
	#include "/import/gbufferModelViewInverse.glsl"
	#ifdef DISTANT_HORIZONS
		float fogAmount = float(depth == 1.0 && depthDh == 1.0);
	#else
		float fogAmount = getBorderFogAmount(transform(gbufferModelViewInverse, viewPos)  ARGS_IN);
	#endif
	
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	playerPos.y *= 0.02;
	float distMult = playerPos.y < 0.0 ? sqrt(1.0 - playerPos.y) : 1.0 / (playerPos.y * 0.5 + 1.0);
	playerPos.y /= 0.02;
	
	
	
	// ======== AUTO EXPOSURE ======== //
	
	#if AUTO_EXPOSURE_ENABLED == 1
		#include "/import/eyeBrightnessSmooth.glsl"
		vec2 normalizedBrightness = eyeBrightnessSmooth / 240.0;
		#ifdef NETHER
			normalizedBrightness.y = 0.5;
		#elif defined END
			normalizedBrightness.y = 1.0;
		#endif
		normalizedBrightness *= vec2(0.5, 1.0); // weights
		float autoExposureAmount = max(normalizedBrightness.x, normalizedBrightness.y);
		float autoExposureMult = mix(AUTO_EXPOSURE_DARK_MULT, AUTO_EXPOSURE_BRIGHT_MULT, autoExposureAmount);
		autoExposureMult = mix(autoExposureMult, 1.0, fogAmount);
		color *= autoExposureMult;
	#endif
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	float fogDist = length(viewPos);
	fogDist *= distMult;
	vec3 fogColor;
	float fogSlope;
	float fogMax;
	#include "/import/isEyeInWater.glsl"
	if (isEyeInWater == 0) {
		fogColor = getSkyColor(viewPos / fogDist, false  ARGS_IN);
		fogSlope = 325.0 / ATMOSPHERIC_FOG_DENSITY;
		fogMax = 0.5;
	} else if (isEyeInWater == 1) {
		fogColor = vec3(0.0, 0.1, 0.6);
		fogSlope = 5.0;
		fogDist += 4.0;
		fogMax = 0.9;
	} else if (isEyeInWater == 2) {
		fogColor = vec3(0.85, 0.15, 0.0);
		fogSlope = 0.1;
		fogMax = 1.0;
	} else if (isEyeInWater == 3) {
		fogColor = vec3(0.6, 0.9, 1.0);
		fogSlope = 0.1;
		fogMax = 1.0;
	}
	float atmoFogAmount = 1.0 - fogSlope / (fogSlope + fogDist);
	atmoFogAmount *= 1.0 - fogAmount;
	color *= 1.0 - fogMax * atmoFogAmount;
	color += fogColor * atmoFogAmount;
	
	
	
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
		vec3 bloomColor = color * bloomMult;
	#endif
	
	
	
	/* DRAWBUFFERS:1 */
	gl_FragData[0] = vec4(color, 1.0);
	#if BLOOM_ENABLED == 1
		/* DRAWBUFFERS:15 */
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
