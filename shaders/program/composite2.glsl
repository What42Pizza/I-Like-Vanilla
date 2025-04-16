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
#include "/lib/fog/getFogAmount.glsl"

#if BLOOM_ENABLED == 1
	#include "/lib/bloom.glsl"
#endif
#if DEPTH_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_depth.glsl"
#endif
#if VOL_SUNRAYS_ENABLED == 1
	#include "/lib/sunrays_vol.glsl"
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb;
	vec3 noisyAdditions = vec3(0.0);
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh)  ARGS_IN);
		if (dot(viewPosDh, viewPosDh) < dot(viewPos, viewPos)) viewPos = viewPosDh;
	#endif
	
	#ifdef DISTANT_HORIZONS
		float fogAmount = float(depth > 0.9999 && depthDh > 0.9999);
	#else
		#include "/import/gbufferModelView.glsl"
		float fogAmount = getFogAmount(mat3(gbufferModelView) * viewPos  ARGS_IN);
	#endif
	
	
	
	// ======== BLOOM CALCULATIONS ======== //
	
	#if BLOOM_ENABLED == 1
		vec3 bloomAddition = getBloomAddition(depth  ARGS_IN);
		bloomAddition *= 1.0 - fogAmount;
		noisyAdditions += bloomAddition;
	#endif
	
	
	
	// ======== SUNRAYS ======== //
	
	#if DEPTH_SUNRAYS_ENABLED == 1 || VOL_SUNRAYS_ENABLED == 1
		
		#if DEPTH_SUNRAYS_ENABLED == 1
			#include "/import/isSun.glsl"
			vec3 depthSunraysColor = isSun ? SUNRAYS_SUN_COLOR : SUNRAYS_MOON_COLOR;
			#include "/utils/var_rng.glsl"
			vec3 depthSunraysAddition = getDepthSunraysAmount(rng  ARGS_IN) * depthSunraysAmountMult * depthSunraysColor;
			depthSunraysAddition *= 1.0 - 0.8 * fogAmount;
			noisyAdditions += depthSunraysAddition;
		#endif
		#if VOL_SUNRAYS_ENABLED == 1
			#include "/import/sunAngle.glsl"
			vec3 volSunraysColor = sunAngle < 0.5 ? SUNRAYS_SUN_COLOR * 1.25 : SUNRAYS_MOON_COLOR * 1.25;
			float rawVolSunraysAmount = getVolSunraysAmount(viewPos  ARGS_IN) * volSunraysAmountMult;
			rawVolSunraysAmount *= 1.0 - fogAmount;
			float volSunraysAmount = 1.0 / (rawVolSunraysAmount + 1.0);
			color *= 1.0 + (1.0 - volSunraysAmount) * SUNRAYS_BRIGHTNESS_INCREASE * 2.0;
			color = mix(volSunraysColor, color, max(volSunraysAmount, volSunraysAmountMax));
		#endif
		
	#endif
	
	
	/* DRAWBUFFERS:06 */
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(noisyAdditions, 1.0);
	
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
