#include "/utils/getAmbientLight.glsl"





void doSimpleFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specularness, vec3 viewPos, vec3 normal) {
	
	#if defined OVERWORLD || defined END
		float lightDot = dot(normalize(shadowLightPosition), normal);
		//#ifdef SHADOWS_ENABLED
		//	float lightDotLift = 0.3;
		//#else
		//	float lightDotLift = 1.0;
		//#endif
		//// TODO: reintroduce 'SUNLIGHT_CEL_AMOUNT' here?
		//lightDot = lightDotLift * 0.5 + (1.0 - lightDotLift * 0.5) * lightDot;
	#else
		float lightDot = 1.0;
	#endif
	
	// night saturation decrease
	#ifdef OVERWORLD
		float nightPercent = 1.0 - dayPercent;
		nightPercent *= ambientBrightness * (1.0 - blockBrightness);
		nightPercent *= nightPercent;
		nightPercent *= NIGHT_SATURATION_DECREASE;
		color = mix(vec3(getLum(color)), color, 1.0 - nightPercent * 0.1);
		color += nightPercent * 0.06;
	#endif
	
	#ifdef END
		ambientBrightness = 1.0;
	#endif
	
	vec3 ambientLight = getAmbientLight(ambientBrightness, lightDot);
	
	vec3 normalForSS = mat3(gbufferModelViewInverse) * normal;
	// +-1.0x: -0.4
	// +-1.0z: -0.0
	// +1.0y: +0.325
	// -1.0y: -0.65
	normalForSS.xz = abs(normalForSS.xz);
	normalForSS.y *= sign(normalForSS.y) * -0.25 + 0.75; // -1: *1, 1: *0.5
	float sideShading = dot(normalForSS, vec3(-0.4, 0.65, 0.0));
	float brightForSS = max(blockBrightness, ambientBrightness);
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, brightForSS * brightForSS) * 0.75;
	ambientLight *= 1.0 + sideShading;
	#ifdef NETHER
		blockBrightness *= 1.0 + 0.75 * sideShading;
	#else
		blockBrightness *= 1.0 + sideShading;
	#endif
	
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	
	vec3 lighting = ambientLight;
	
	#ifdef OVERWORLD
		lighting += lightningFlashAmount * LIGHTNING_BRIGHTNESS * 0.25 * ambientBrightness * ambientBrightness;
	#endif
	
	#ifdef OVERWORLD
		vec3 reflectedDir = normalize(reflect(viewPos, normal));
		vec3 lightDir = normalize(shadowLightPosition);
		float specular = max(dot(reflectedDir, lightDir), 0.0);
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular *= 1.0 - betterRainStrength;
		vec3 specularColor = shadowcasterLight * (sunAngle < 0.5 ? vec3(1.0, 1.0, 0.6) : vec3(0.5, 0.7, 0.9) * 0.75);
		#if PBR_TYPE == 0
			specular *= 1.0 - 0.25 * getSaturation(color);
		#endif
		lighting += specularColor * specular * (0.1 + 0.5 * specularness) * clamp(lightDot * 64.0, 0.0, 1.0) * min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	#endif
	
	//blockBrightness *= 1.25 - min(getLum(lighting), 1.0);
	//lighting *= 1.0 - 0.25 * blockBrightness;
	
	//blockBrightness = 1.0 - (1.0 - blockBrightness) * (1.0 - blockBrightness);
	const float blockBrightnessCurve = 0.25;
	blockBrightness = -1.0 * blockBrightnessCurve * blockBrightness * blockBrightness + blockBrightnessCurve * blockBrightness + blockBrightness;
	#ifdef OVERWORLD
		blockBrightness *= 1.0 + ambientBrightness * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	vec3 blockLight = mix(BLOCK_COLOR_DARK, BLOCK_COLOR_BRIGHT, blockBrightness * blockBrightness) * blockBrightness;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	//lighting += blockLight;
	lighting = smoothMax(lighting, blockLight, 0.1);
	
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 nightVisionMin = vec3(betterNightVision);
	nightVisionMin.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT;
	nightVisionMin *= 1.0 + 0.5 * sideShading;
	lighting += nightVisionMin * (1.0 - 0.25 * getLum(lighting));
	
	#if DO_COLOR_CODED_GBUFFERS == 1
		lighting = vec3(1.0);
	#endif
	color *= lighting;
	
}
