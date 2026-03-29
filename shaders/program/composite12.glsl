in_out vec2 texcoord;



#if BLOOM_QUALITY == 1
	#define SAMPLE_COUNT 3
	const float stepAmount = 0.4 * BLOOM_SIZE * 0.1;
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.852, 0.527, 0.23);
	const float weightsTotal = 4.218;
#elif BLOOM_QUALITY == 2
	#define SAMPLE_COUNT 4
	const float stepAmount = 0.32 * BLOOM_SIZE * 0.1;
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.902, 0.664, 0.398, 0.194);
	const float weightsTotal = 5.316;
#elif BLOOM_QUALITY == 3
	#define SAMPLE_COUNT 6
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.9394131, 0.7788008, 0.56978285, 0.36787945, 0.2096114, 0.10539923);
	const float weightsTotal = 6.9417734;
#elif BLOOM_QUALITY == 4
	#define SAMPLE_COUNT 8
	const float stepAmount = 0.17 * BLOOM_SIZE * 0.1;
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.971, 0.891, 0.771, 0.63, 0.486, 0.353, 0.243, 0.157);
	const float weightsTotal = 10.004;
#elif BLOOM_QUALITY == 5
	#define SAMPLE_COUNT 12
	const float stepAmount = 0.115 * BLOOM_SIZE * 0.1;
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.986, 0.948, 0.888, 0.81, 0.718, 0.621, 0.523, 0.429, 0.343, 0.266, 0.212, 0.149);
	const float weightsTotal = 14.786;
#endif



#ifdef FSH

const bool colortex4MipmapEnabled = true;

#include "/utils/depth.glsl"

void main() {
	#if HORROR_MODE == 1
		discard;
		return;
	#endif
	
	const int bloomIntScale = 1 << BLOOM_RENDER_SCALE;
	vec2 stepDir = vec2(0.0, 1.0) * BLOOM_SIZE * 0.1 / SAMPLE_COUNT;
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord * bloomIntScale + bloomIntScale / 2, 0).r;
	float blockDepth = toBlockDepth(depth);
	stepDir /= blockDepth * 0.125 + 1.0;
	
	vec3 bloomColor = texture2DLod(BLOOM_TEXTURE, texcoord, 2).rgb;
	for (int i = 0; i < SAMPLE_COUNT; i++) {
		vec2 offset = stepDir * (i + 1);
		bloomColor += texture2DLod(BLOOM_TEXTURE, texcoord + offset, 2).rgb * sampleWeights[i];
		bloomColor += texture2DLod(BLOOM_TEXTURE, texcoord - offset, 2).rgb * sampleWeights[i];
	}
	bloomColor /= weightsTotal;
	
	/* DRAWBUFFERS:4 */
	gl_FragData[0] = vec4(bloomColor, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
}

#endif
