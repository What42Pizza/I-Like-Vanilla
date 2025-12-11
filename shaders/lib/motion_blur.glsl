const int SAMPLE_COUNT = MOTION_BLUR_QUALITY * MOTION_BLUR_QUALITY;

void doMotionBlur(inout vec3 color, vec2 prevCoord) {
	color *= color;
	
	vec2 coordStep = (prevCoord - texcoord) * invFrameTime;
	coordStep *= MOTION_BLUR_AMOUNT * 0.01;
	coordStep /= SAMPLE_COUNT;
	vec2 pos = texcoord;
	#include "/utils/var_rng.glsl"
	pos += coordStep * randomFloat(rng);
	
	for (int i = 0; i < SAMPLE_COUNT; i++) {
		pos += coordStep;
		vec3 sample = texture2DLod(PREV_TEXTURE, pos, 0).rgb * 2.0;
		color += sample * sample;
	}
	color /= SAMPLE_COUNT + 1;
	
	color = sqrt(color);
}
