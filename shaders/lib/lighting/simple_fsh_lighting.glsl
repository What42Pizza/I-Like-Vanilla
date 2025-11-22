#include "/utils/getAmbientLight.glsl"



float getShadowBrightness(vec3 viewPos, vec3 normal, float ambientBrightness) {
	
	// get normal dot sun/moon pos
	#if defined OVERWORLD || defined END
		float lightDot = dot(normalize(shadowLightPosition), normal);
	#else
		float lightDot = 1.0;
	#endif
	
	float shadowBrightness = ambientBrightness;
	
	const float SUNLIGHT_CEL_INTERMEDIATE = 1.0 - (1.0 - SUNLIGHT_CEL_AMOUNT) * (1.0 - SUNLIGHT_CEL_AMOUNT);
	const float SUNLIGHT_CEL_SHADING_MULT = 1.0 / (1.01 - SUNLIGHT_CEL_INTERMEDIATE);
	shadowBrightness *= clamp(lightDot * SUNLIGHT_CEL_SHADING_MULT, 0.0, 1.0);
	
	return shadowBrightness;
}





void doSimpleFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specularness, vec3 viewPos, vec3 normal) {
	
	#if AMBIENT_CEL_AMOUNT != 0
		ambientBrightness = sqrt(ambientBrightness);
		ambientBrightness = mix(ambientBrightness, floor(ambientBrightness * 3.0 + 0.5) / 3.0, AMBIENT_CEL_AMOUNT / 100.0);
		ambientBrightness *= ambientBrightness;
	#endif
	#if BLOCKLIGHT_CEL_AMOUNT != 0
		blockBrightness = sqrt(blockBrightness);
		blockBrightness = mix(blockBrightness, floor(blockBrightness * 3.0 + 0.5) / 3.0, BLOCKLIGHT_CEL_AMOUNT / 100.0);
		blockBrightness *= blockBrightness;
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
	
	vec3 ambientLight = getAmbientLight(ambientBrightness);
	
	vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;
	worldNormal.xz = abs(worldNormal.xz);
	float sideShading = dot(worldNormal, vec3(-0.5, 0.3, -0.3));
	sideShading *= mix(SIDE_SHADING_DARK, SIDE_SHADING_BRIGHT, max(blockBrightness, ambientBrightness)) * 0.85;
	ambientLight *= 1.0 + sideShading;
	blockBrightness *= 1.0 + sideShading;
	
	#if BLOCK_BRIGHTNESS_CURVE == 2
		blockBrightness = pow2(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 3
		blockBrightness = pow3(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 4
		blockBrightness = pow4(blockBrightness);
	#elif BLOCK_BRIGHTNESS_CURVE == 5
		blockBrightness = pow5(blockBrightness);
	#endif
	
	float shadowBrightness = getShadowBrightness(viewPos, normal, ambientBrightness);
	shadowBrightness *= min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	shadowBrightness *= ambientBrightness;
	float rainDecrease = rainStrength * dayPercent * (1.0 - WEATHER_BRIGHTNESS_MULT);
	shadowBrightness *= 1.0 - rainDecrease;
	
	vec3 skyLighting = shadowcasterLight * shadowBrightness;
	skyLighting *= 1.0 + 0.5 * sideShading;
	ambientLight *= 1.0 - shadowBrightness;
	
	vec3 lighting = ambientLight + skyLighting;
	
	float betterNightVision = nightVision;
	if (betterNightVision > 0.0) {
		betterNightVision = 0.6 + 0.2 * betterNightVision;
		betterNightVision *= NIGHT_VISION_BRIGHTNESS;
	}
	vec3 betterNightVisionChannels = vec3(betterNightVision);
	betterNightVisionChannels.rb *= 1.0 - NIGHT_VISION_GREEN_AMOUNT;
	lighting = betterNightVisionChannels + (1.0 - betterNightVisionChannels) * lighting;
	
	#ifdef OVERWORLD
		vec3 reflectedDir = normalize(reflect(viewPos, normal));
		vec3 lightDir = normalize(shadowLightPosition);
		float specular = max(dot(reflectedDir, lightDir), 0.0);
		specular *= specular;
		specular *= specular;
		specular = 1.0 - (1.0 - specular) * (1.0 - specular);
		specular *= 1.0 - betterRainStrength;
		vec3 specularColor = shadowcasterLight * (sunAngle < 0.5 ? vec3(1.0, 1.0, 0.25) : vec3(0.5, 0.7, 0.9) * 0.75);
		specularness *= 1.0 - getSaturation(color);
		lighting += specularColor * specular * (0.15 + 0.85 * specularness) * shadowBrightness;
	#endif
	
	blockBrightness *= 1.2 - min(getLum(lighting), 1.0);
	#ifdef OVERWORLD
		blockBrightness *= 1.0 + ambientBrightness * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	lighting += blockLight;
	
	color *= lighting;
	
}
