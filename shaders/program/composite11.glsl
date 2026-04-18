in_out vec2 texcoord;



/*
Generated using this rust code:
let count = 8;
let mut total = 0.0;
for x in -count..=count {
	for y in -count..=count {
		let fx = x as f32 / count as f32 * 1.73081845045;
		let fy = x as f32 / count as f32 * 1.73081845045;
		let vx = f32::consts::E.powf(fx * fx * -1.);
		let vy = f32::consts::E.powf(fy * fy * -1.);
		if y == 0 { println!("{vx}"); }
		total += vx * vy;
	}
}
println!("{}", total);
*/

#if BLOOM_QUALITY == 1
	#define HALF_SAMPLE_COUNT 3
	#define SAMPLE_COUNT (HALF_SAMPLE_COUNT * 2 + 1)
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.050000004, 0.2640976, 0.71687114, 1, 0.71687114, 0.2640976, 0.050000004);
	const float weightsTotal = 15.206126;
#elif BLOOM_QUALITY == 2
	#define HALF_SAMPLE_COUNT 4
	#define SAMPLE_COUNT (HALF_SAMPLE_COUNT * 2 + 1)
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.050000004, 0.185426, 0.4728708, 0.8292503, 1, 0.8292503, 0.4728708, 0.185426, 0.050000004);
	const float weightsTotal = 26.066614;
#elif BLOOM_QUALITY == 3
	#define HALF_SAMPLE_COUNT 6
	#define SAMPLE_COUNT (HALF_SAMPLE_COUNT * 2 + 1)
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.050000004, 0.12488407, 0.2640976, 0.4728708, 0.71687114, 0.9201535, 1, 0.9201535, 0.71687114, 0.4728708, 0.2640976, 0.12488407, 0.050000004);
	const float weightsTotal = 56.47294;
#elif BLOOM_QUALITY == 4
	#define HALF_SAMPLE_COUNT 8
	#define SAMPLE_COUNT (HALF_SAMPLE_COUNT * 2 + 1)
	const float sampleWeights[SAMPLE_COUNT] = float[SAMPLE_COUNT] (0.050000004, 0.10090181, 0.185426, 0.31030244, 0.4728708, 0.6562097, 0.8292503, 0.9542703, 1, 0.9542703, 0.8292503, 0.6562097, 0.4728708, 0.31030244, 0.185426, 0.10090181, 0.050000004);
	const float weightsTotal = 98.45921;
#endif



#ifdef FSH

const bool colortex4MipmapEnabled = true;

void doBloomTile(inout vec3 bloomColor, vec2 stepAmount) {
	for (int x = -HALF_SAMPLE_COUNT; x <= HALF_SAMPLE_COUNT; x++) {
		for (int y = -HALF_SAMPLE_COUNT; y <= HALF_SAMPLE_COUNT; y++) {
			vec2 offset = stepAmount * (vec2(x, y) / HALF_SAMPLE_COUNT);
			float weight = sampleWeights[x + HALF_SAMPLE_COUNT] * sampleWeights[y + HALF_SAMPLE_COUNT];
			bloomColor += texture2DLod(BLOOM_TEXTURE, texcoord + offset, 2).rgb * weight;
		}
	}
}

void main() {
	#if HORROR_MODE == 1
		discard;
		return;
	#endif
	
	vec2 stepAmount = vec2(invAspectRatio, 1.0) * BLOOM_SIZE * 0.03;
	vec3 bloomColor = vec3(0.0);
	
	doBloomTile(bloomColor, stepAmount);
	stepAmount *= 2.0;
	doBloomTile(bloomColor, stepAmount);
	stepAmount *= 2.0;
	doBloomTile(bloomColor, stepAmount);
	
	bloomColor /= weightsTotal * 3.0;
	
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
