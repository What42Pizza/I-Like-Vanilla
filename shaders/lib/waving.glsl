#ifdef FIRST_PASS
	const float[4] wavingScales = float[4] (0.0, WAVING_AMOUNT_1, WAVING_AMOUNT_2, WAVING_AMOUNT_3);
	const vec3 windDirection = vec3(1.0, 0.1, 0.3); // another way to think of it: weights for timePos influence
#endif



vec3 getWavingAddition(vec3 playerPos  ARGS_OUT) {
	#include "/import/cameraPosition.glsl"
	vec3 worldPos = playerPos + cameraPosition;
	#include "/import/frameTimeCounter.glsl"
	float timePos = frameTimeCounter + dot(worldPos, windDirection) * WAVING_WORLD_SCALE * 0.5;
	timePos *= WAVING_SPEED * 1.75;
	uint timePosFloor = uint(int(timePos));
	vec3 pos1 = randomVec3FromRValue(timePosFloor);
	vec3 pos2 = randomVec3FromRValue(timePosFloor + 1u);
	vec3 pos3 = randomVec3FromRValue(timePosFloor + 2u);
	vec3 pos4 = randomVec3FromRValue(timePosFloor + 3u);
	vec3 wavingAmount = cubicInterpolate(pos1, pos2, pos3, pos4, mod(timePos, 1.0)) * vec3(1.0, 0.2, 1.0) * 0.075;
	//timePos *= WAVING_SPEED * 0.4;
	//float x = simplexNoise(vec2(timePos, 0));
	//float y = simplexNoise(vec2(timePos, 10)) * 0.5;
	//float z = simplexNoise(vec2(timePos, 20));
	//vec3 wavingAmount = vec3(x, y, z) * 0.05;
	#if HEIGHT_BASED_WAVING_ENABLED == 1
		const float lowY = 16.0;
		const float lowMult = 0.0;
		const float highY = 224.0;
		const float highMult = 2.0;
		wavingAmount *= clamp((worldPos.y - lowY) * (highMult - lowMult) / (highY - lowY) + lowMult, 0.0, 1.75);
	#endif
	return wavingAmount;
}



void applyWaving(inout vec3 position  ARGS_OUT) {
	#include "/import/mc_Entity.glsl"
	int materialId = int(mc_Entity.x);
	if (materialId < 1000) return;
	int wavingData = materialId % 10;
	if (wavingData < 2 || wavingData > 7) return;
	#include "/import/mc_midTexCoord.glsl"
	if (wavingData % 2 == 0 && gl_MultiTexCoord0.y > mc_midTexCoord.y) return; // don't apply waving to base
	float wavingScale = wavingScales[wavingData / 2];
	#ifndef SHADER_SHADOW
		wavingScale *= max(1.0 - 3.0 * (1.0 - lmcoord.y), 0.0);
		if (wavingScale == 0.0) return;
	#endif
	#include "/import/betterRainStrength.glsl"
	wavingScale *= 1.0 + betterRainStrength * (WAVING_WEATHER_MULT - 1.0);
	#include "/import/ambientMoonPercent.glsl"
	wavingScale *= 1.0 - ambientMoonPercent * (1.0 - WAVING_NIGHT_MULT);
	position += getWavingAddition(position  ARGS_IN) * wavingScale;
}
