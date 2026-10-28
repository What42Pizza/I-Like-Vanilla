in_out vec2 texcoord;

flat in_out float fogDensity;
flat in_out float fogDarken;
flat in_out float extraFogDist;
flat in_out float distMultMult;



#ifdef FSH

#include "/utils/projections.glsl"
#include "/utils/borderFogAmount.glsl"

#include "/utils/getFogColor.glsl"

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	#if defined OVERWORLD && defined VOL_CLOUDS_ENABLED
		bool isCloud = unpack_7_7_1_1(texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0).y).z > 0.5;
	#else
		const bool isCloud = false;
	#endif
	
	#if FOG_IGNORES_TRANSPARENTS == 0
		float depth;
		if (isCloud) depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		else depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	#elif FOG_IGNORES_TRANSPARENTS == 1
		float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	#endif
	vec3 viewPos = screenToView(vec3(texcoord, depth));
	#ifdef DISTANT_HORIZONS
		#if FOG_IGNORES_TRANSPARENTS == 0
			float depthDh;
			if (isCloud) depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
			else depthDh = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		#elif FOG_IGNORES_TRANSPARENTS == 1
			float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		#endif
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh));
		if (viewPosDh.z > viewPos.z) viewPos = viewPosDh;
	#endif
	#ifdef VOXY
		// this does slightly fix something but idk if it's worth it
		//float depthVx = texelFetch(VX_DEPTH_BUFFER_OPAQUE, texelcoord, 0).r;
		//if (depthVx != 1.0) viewPos = screenToViewVx(vec3(texcoord, depthVx));
		//float depthVxTrans = texelFetch(VX_DEPTH_BUFFER_TRANS, texelcoord, 0).r;
		//if (depthVxTrans != 1.0) viewPos = screenToViewVx(vec3(texcoord, depthVxTrans));
	#endif
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	
	
	#ifdef DISTANT_HORIZONS
		//float dhTransparentDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		//vec3 dhTransparentViewPos = screenToViewDh(vec3(texcoord, dhTransparentDepth));
		//if (dhTransparentViewPos.z > viewPos.z - 0.5 || depth > fromLinearDepth(0.9)) {
		//	vec4 dhTransparents = texelFetch(VOXY_TRANSPARENTS_TEXTURE, texelcoord, 0);
		//	dhTransparents.rgb *= 2.0;
		//	dhTransparents.a *= float(!depthIsHand(depth));
		//	color.rgb = mix(color.rgb, dhTransparents.rgb, dhTransparents.a);
		//}
	#endif
	
	
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
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	vec2 brightnesses = eyeBrightnessSmooth / 240.0;
	float fogDist = length(playerPos);
	fogDist *= 1.0 + distMult * distMultMult;
	
	float fogDarken = fogDarken;
	vec3 atmoFogColor = getFogColor(viewPos);
	atmoFogColor *= 1.0 - blindness;
	atmoFogColor *= 1.0 - darknessFactor;
	#ifndef NETHER
		if (isEyeInWater == 0) {
			atmoFogColor *= 0.5 + 0.5 * brightnesses.y;
		}
	#endif
	
	fogDist = mix(fogDist, 0.0, fogAmount);
	fogDist = smoothMax(fogDist + extraFogDist, 0.0, 0.2);
	float atmoFogAmount = 1.0 - exp(-fogDensity * fogDist);
	#ifndef NETHER
		atmoFogAmount *= 1.0 - 0.25 * float(isEyeInWater == 0) * (1.0 - blindness) * (1.0 - darknessFactor);
	#endif
	color *= 1.0 - min(atmoFogAmount * fogDarken, 1.0);
	color += atmoFogColor * atmoFogAmount;
	
	color *= 1.0 - 0.25 * blindness;
	
	#if defined OVERWORLD && HBD_ENABLED == 1
		float desaturationAmount = 1.0 - HBD_SCALE / (max(playerPos.y + cameraPosition.y - 64.0, 0) + HBD_SCALE);
		desaturationAmount *= 1.0 - fogAmount;
		desaturationAmount *= HBD_STRENGTH * 0.75;
		color.rgb = mix(color.rgb, vec3(getLum(color.rgb) + 0.1), desaturationAmount);
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
	
	
	
	// ======== ATMOSPHERIC FOG ======== //
	
	distMultMult = 1.0;
	if (isEyeInWater == 0) {
		float skylightExposure = eyeBrightnessSmooth.y / 240.0;
		#ifdef OVERWORLD
			fogDensity =
				DAY_ATMOSPHERIC_FOG_DENSITY * ambientSunPercent
				+ NIGHT_ATMOSPHERIC_FOG_DENSITY * ambientMoonPercent
				+ SUNRISE_ATMOSPHERIC_FOG_DENSITY * ambientSunrisePercent
				+ SUNSET_ATMOSPHERIC_FOG_DENSITY * ambientSunsetPercent;
			fogDensity = mix(UNDERGROUND_FOG_DENSITY, fogDensity, min(skylightExposure * 1.5, 1.0));
			fogDensity = mix(fogDensity, WEATHER_FOG_DENSITY, betterRainStrength * skylightExposure);
			fogDensity = mix(fogDensity, mix(PALE_GARDEN_FOG_NIGHT_DENSITY, PALE_GARDEN_FOG_DENSITY, dayPercent), inPaleGarden);
		#elif defined NETHER
			fogDensity = NETHER_FOG_DENSITY;
		#elif defined END
			fogDensity = END_FOG_DENSITY;
		#endif
		fogDensity /= 256.0;
		#ifdef OVERWORLD
			fogDarken = 1.1;
			fogDarken = mix(fogDarken, 0.85, betterRainStrength * skylightExposure);
		#elif defined NETHER
			fogDarken = 0.75;
		#else
			fogDarken = 1.0;
		#endif
		extraFogDist = 2.0 * inPaleGarden;
		extraFogDist += betterRainStrength * 8.0;
		#if USE_VANILLA_FOG_DENSITY == 1 && !defined END
			fogDensity /= pow(fogEnd * 0.0012, 1.5);
		#endif
	} else if (isEyeInWater == 1) {
		fogDensity = WATER_FOG_DENSITY * 0.2;
		fogDarken = 1.0;
		extraFogDist = 48.0;
	} else if (isEyeInWater == 2) {
		fogDensity = LAVA_FOG_DENSITY * 0.2;
		fogDarken = 1.0;
		extraFogDist = 1.5;
	} else if (isEyeInWater == 3) {
		fogDensity = POWDERED_SNOW_FOG_DENSITY * 0.2;
		fogDarken = 1.0;
		extraFogDist = 1.0;
	} else {
		fogDensity = 1.0;
		fogDarken = 1.0;
		extraFogDist = 0.0;
	}
	
	fogDensity = mix(fogDensity, BLINDNESS_EFFECT_FOG_DENSITY / 64.0, blindness);
	fogDarken = mix(fogDarken, 1.0, blindness);
	extraFogDist = mix(extraFogDist, BLINDNESS_EFFECT_FOG_DENSITY / -30.0, blindness);
	distMultMult *= 1.0 - blindness;
	
	fogDensity = mix(fogDensity, DARKNESS_EFFECT_FOG_DENSITY / 100.0, darknessFactor);
	fogDarken = mix(fogDarken, 1.0, darknessFactor);
	extraFogDist = mix(extraFogDist, DARKNESS_EFFECT_FOG_DENSITY / -3.0, darknessFactor);
	distMultMult *= 1.0 - darknessFactor;
	
	
	
}

#endif
