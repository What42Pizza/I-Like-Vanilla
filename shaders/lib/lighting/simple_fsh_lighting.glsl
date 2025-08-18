#include "/utils/getAmbientLight.glsl"



float getShadowBrightness(vec3 viewPos, vec3 normal, float ambientBrightness  ARGS_OUT) {
	
	// get normal dot sun/moon pos
	#ifdef OVERWORLD
		#include "/import/shadowLightPosition.glsl"
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





void doSimpleFshLighting(inout vec3 color, float blockBrightness, float ambientBrightness, float specular_amount, vec3 viewPos, vec3 normal  ARGS_OUT) {
	
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
	
	#if HANDHELD_LIGHT_ENABLED == 1
		float viewPosLen = length(viewPos);
		if (viewPosLen <= HANDHELD_LIGHT_DISTANCE) {
			float handLightBrightness = max(1.0 - viewPosLen / HANDHELD_LIGHT_DISTANCE, 0.0);
			#include "/import/heldBlockLightValue.glsl"
			handLightBrightness *= heldBlockLightValue / 15.0 * HANDHELD_LIGHT_BRIGHTNESS;
			blockBrightness = max(blockBrightness, handLightBrightness);
		}
	#endif
	
	// night saturation decrease
	#include "/import/dayPercent.glsl"
	float nightPercent = 1.0 - dayPercent;
	nightPercent *= ambientBrightness * (1.0 - blockBrightness);
	nightPercent *= nightPercent;
	nightPercent *= NIGHT_SATURATION_DECREASE;
	color = mix(vec3(getLum(color)), color, 1.0 - nightPercent * 0.1);
	color += nightPercent * 0.06;
	
	#ifdef END
		ambientBrightness = 1.0;
	#endif
	
	vec3 ambientLight = getAmbientLight(ambientBrightness  ARGS_IN);
	
	#if BLOCKLIGHT_FLICKERING_ENABLED == 1
		#include "/import/blockFlickerAmount.glsl"
		blockBrightness *= 1.0 + (blockFlickerAmount - 1.0) * BLOCKLIGHT_FLICKERING_AMOUNT;
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
	#include "/import/moonLightBrightness.glsl"
	#ifdef OVERWORLD
		#include "/import/eyeBrightness.glsl"
		blockBrightness *= 1.0 + (eyeBrightness.y / 240.0) * moonLightBrightness * (BLOCK_BRIGHTNESS_NIGHT_MULT - 1.0);
	#endif
	
	#include "/import/sunLightBrightness.glsl"
	float shadowBrightness = getShadowBrightness(viewPos, normal, ambientBrightness  ARGS_IN);
	shadowBrightness *= min((sunLightBrightness + moonLightBrightness) * 5.0, 1.0);
	shadowBrightness *= ambientBrightness;
	#include "/import/rainStrength.glsl"
	float rainDecrease = rainStrength * dayPercent * (1.0 - WEATHER_BRIGHTNESS_MULT);
	shadowBrightness *= 1.0 - rainDecrease;
	
	vec3 skyLighting = shadowcasterLight * shadowBrightness;
	ambientLight *= 1.0 - shadowBrightness;
	
	vec3 lighting = ambientLight + skyLighting;
	
	#include "/import/nightVision.glsl"
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
		#include "/import/shadowLightPosition.glsl"
		vec3 lightDir = normalize(shadowLightPosition);
		float specular = max(dot(reflectedDir, lightDir), 0.0);
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular *= specular;
		specular = 1.0 - (1.0 - specular) * (1.0 - specular);
		#include "/import/betterRainStrength.glsl"
		specular *= 1.0 - betterRainStrength;
		#include "/import/sunAngle.glsl"
		#include "/import/ambientMoonPercent.glsl"
		vec3 specularColor = sunAngle < 0.5 ? vec3(1.0, 1.0, 0.5) : vec3(0.5, 0.7, 0.9);
		lighting += specularColor * specular * (0.2 + 0.7 * specular_amount) * shadowBrightness * (1.0 - 0.8 * ambientMoonPercent);
	#endif
	
	float lightingBrightness = min(getLum(lighting), 1.0);
	blockBrightness *= 1.2 - lightingBrightness;
	vec3 blockLight = blockBrightness * BLOCK_COLOR;
	#ifdef NETHER
		blockLight *= mix(vec3(1.0), NETHER_BLOCKLIGHT_MULT, blockBrightness);
	#endif
	lighting += blockLight;
	
	color *= lighting;
	
}
