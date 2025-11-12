const vec3 windDirection = vec3(1.0, 0.1, 0.3); // another way to think of it: weights for timePos influence



vec3 getWavingAddition(vec3 playerPos) {
	vec3 worldPos = playerPos + cameraPosition;
	float timePos = frameTimeCounter + dot(worldPos, windDirection) * WAVING_WORLD_SCALE * 0.5;
	timePos *= WAVING_SPEED * 1.75;
	uint timePosFloor = uint(int(timePos));
	vec3 pos1 = randomVec3FromRValue(timePosFloor);
	vec3 pos2 = randomVec3FromRValue(timePosFloor + 1u);
	vec3 pos3 = randomVec3FromRValue(timePosFloor + 2u);
	vec3 pos4 = randomVec3FromRValue(timePosFloor + 3u);
	vec3 wavingAmount = cubicInterpolate(pos1, pos2, pos3, pos4, fract(timePos)) * vec3(1.0, 0.2, 1.0) * 0.075;
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



void applyWaving(inout vec3 position, uint materialId) {
	uint encodedData = materialId >> 10u;
	uint wavingScaleIndex = (encodedData & 7u) >> 1u;
	float wavingScale;
	if (wavingScaleIndex < 2u) {
		if (wavingScaleIndex == 0u) return;
		wavingScale = WAVING_AMOUNT_1;
	} else {
		if (wavingScaleIndex == 2u) wavingScale = WAVING_AMOUNT_2;
		else wavingScale = WAVING_AMOUNT_3;
	}
	if (encodedData > 7u && gl_MultiTexCoord0.y > mc_midTexCoord.y) return; // don't apply waving to base
	#ifndef SHADER_SHADOW
		wavingScale *= max(1.0 - 3.0 * (1.0 - lmcoord.y), 0.0);
		if (wavingScale == 0.0) return;
	#endif
	wavingScale *= 1.0 + betterRainStrength * (WAVING_WEATHER_MULT - 1.0);
	wavingScale *= 1.0 - ambientMoonPercent * (1.0 - WAVING_NIGHT_MULT);
	position += getWavingAddition(position) * wavingScale;
}
