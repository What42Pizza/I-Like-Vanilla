#include "/utils/depth.glsl"



void addBloom(inout vec3 color) {
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float blockDepth = toBlockDepth(depth);
	float sizeMult = inversesqrt(blockDepth) * BLOOM_SIZE * 0.2;
	
	#ifdef GRADIENT_NOISE_SPEED
		#undef GRADIENT_NOISE_SPEED
	#endif
	#define GRADIENT_NOISE_SPEED 21.0015
	#include "/utils/var_gradient_noise.glsl"
	
	float randomAngle = (noise - 0.5) * 2.0 * PI;
	mat2 rotationMatrix;
	rotationMatrix[0] = vec2(cos(randomAngle), -sin(randomAngle)) * invAspectRatio;
	rotationMatrix[1] = vec2(sin(randomAngle), cos(randomAngle));
	
	// these values were generated with https://github.com/What42Pizza/Small-Rust-Programs/tree/master/point-distribution
	vec3 bloomAddition = vec3(0.0);
	#if BLOOM_QUALITY == 1
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.153,  0.067)) * sizeMult).rgb * 0.977;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.236, -0.235)) * sizeMult).rgb * 0.910;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.442,  0.234)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.280, -0.605)) * sizeMult).rgb * 0.685;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.186,  0.812)) * sizeMult).rgb * 0.554;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.994,  0.113)) * sizeMult).rgb * 0.427;
		bloomAddition *= 2.0;
		bloomAddition /= 4.362;
	#elif BLOOM_QUALITY == 2
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.096,  0.028)) * sizeMult).rgb * 0.992;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.082, -0.183)) * sizeMult).rgb * 0.967;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.278,  0.113)) * sizeMult).rgb * 0.926;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.071,  0.394)) * sizeMult).rgb * 0.873;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.450, -0.219)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.507,  0.321)) * sizeMult).rgb * 0.736;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.084, -0.695)) * sizeMult).rgb * 0.659;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.652, -0.464)) * sizeMult).rgb * 0.580;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.236,  0.868)) * sizeMult).rgb * 0.502;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.938,  0.347)) * sizeMult).rgb * 0.427;
		bloomAddition *= 2.0;
		bloomAddition /= 7.472;
	#elif BLOOM_QUALITY == 3
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.057,  0.025)) * sizeMult).rgb * 0.997;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.088, -0.088)) * sizeMult).rgb * 0.987;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.178,  0.058)) * sizeMult).rgb * 0.971;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.080, -0.237)) * sizeMult).rgb * 0.948;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.103,  0.295)) * sizeMult).rgb * 0.920;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.362, -0.098)) * sizeMult).rgb * 0.887;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.159,  0.408)) * sizeMult).rgb * 0.850;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.419,  0.273)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.308, -0.471)) * sizeMult).rgb * 0.764;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.600, -0.176)) * sizeMult).rgb * 0.717;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.099, -0.680)) * sizeMult).rgb * 0.669;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.665,  0.347)) * sizeMult).rgb * 0.620;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.655, -0.481)) * sizeMult).rgb * 0.571;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.375,  0.791)) * sizeMult).rgb * 0.522;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.923,  0.163)) * sizeMult).rgb * 0.474;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.313,  0.950)) * sizeMult).rgb * 0.427;
		bloomAddition *= 2.0;
		bloomAddition /= 12.133;
	#elif BLOOM_QUALITY == 4
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.028,  0.031)) * sizeMult).rgb * 0.999;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.079,  0.026)) * sizeMult).rgb * 0.994;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.108, -0.062)) * sizeMult).rgb * 0.987;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.062, -0.155)) * sizeMult).rgb * 0.977;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.018,  0.208)) * sizeMult).rgb * 0.964;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.214,  0.129)) * sizeMult).rgb * 0.948;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.284, -0.068)) * sizeMult).rgb * 0.930;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.127, -0.308)) * sizeMult).rgb * 0.910;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.281,  0.248)) * sizeMult).rgb * 0.887;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.385, -0.158)) * sizeMult).rgb * 0.863;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.263, -0.376)) * sizeMult).rgb * 0.836;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.182,  0.466)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.501,  0.207)) * sizeMult).rgb * 0.779;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.581,  0.056)) * sizeMult).rgb * 0.749;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.014, -0.625)) * sizeMult).rgb * 0.717;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.271,  0.609)) * sizeMult).rgb * 0.685;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.652, -0.277)) * sizeMult).rgb * 0.653;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.417, -0.623)) * sizeMult).rgb * 0.620;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.748, -0.260)) * sizeMult).rgb * 0.587;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.712,  0.433)) * sizeMult).rgb * 0.554;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.437, -0.758)) * sizeMult).rgb * 0.522;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.104,  0.911)) * sizeMult).rgb * 0.490;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.641,  0.712)) * sizeMult).rgb * 0.458;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.971,  0.237)) * sizeMult).rgb * 0.427;
		bloomAddition *= 2.0;
		bloomAddition /= 18.345;
	#elif BLOOM_QUALITY == 5
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.032, -0.172)) * sizeMult).rgb * 0.999;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.142,  0.141)) * sizeMult).rgb * 0.997;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.190,  0.120)) * sizeMult).rgb * 0.993;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.045,  0.246)) * sizeMult).rgb * 0.988;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.253, -0.109)) * sizeMult).rgb * 0.982;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.132, -0.269)) * sizeMult).rgb * 0.974;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.189, -0.264)) * sizeMult).rgb * 0.965;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.342,  0.076)) * sizeMult).rgb * 0.954;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.180,  0.329)) * sizeMult).rgb * 0.942;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.344, -0.204)) * sizeMult).rgb * 0.929;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.425, -0.007)) * sizeMult).rgb * 0.915;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.115, -0.435)) * sizeMult).rgb * 0.900;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.425,  0.212)) * sizeMult).rgb * 0.883;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.285,  0.411)) * sizeMult).rgb * 0.866;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.152, -0.502)) * sizeMult).rgb * 0.848;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.063,  0.546)) * sizeMult).rgb * 0.828;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.421, -0.392)) * sizeMult).rgb * 0.809;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.462,  0.383)) * sizeMult).rgb * 0.788;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.212,  0.588)) * sizeMult).rgb * 0.767;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.629, -0.163)) * sizeMult).rgb * 0.745;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.657,  0.155)) * sizeMult).rgb * 0.723;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.544, -0.441)) * sizeMult).rgb * 0.701;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.699, -0.194)) * sizeMult).rgb * 0.678;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.348, -0.664)) * sizeMult).rgb * 0.655;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.018, -0.775)) * sizeMult).rgb * 0.632;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.787,  0.143)) * sizeMult).rgb * 0.608;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.646,  0.513)) * sizeMult).rgb * 0.585;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.383, -0.759)) * sizeMult).rgb * 0.562;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2(-0.347,  0.803)) * sizeMult).rgb * 0.539;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.747, -0.501)) * sizeMult).rgb * 0.516;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.525,  0.762)) * sizeMult).rgb * 0.493;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.077,  0.947)) * sizeMult).rgb * 0.471;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.974, -0.054)) * sizeMult).rgb * 0.449;
		bloomAddition += texture2D(BLOOM_TEXTURE, texcoord + (rotationMatrix * vec2( 0.883,  0.470)) * sizeMult).rgb * 0.427;
		bloomAddition *= 2.0;
		bloomAddition /= 26.110;
	#endif
	
	#ifdef OVERWORLD
		const float bloomAmount = BLOOM_AMOUNT;
	#endif
	#ifdef NETHER
		const float bloomAmount = BLOOM_NETHER_AMOUNT;
	#endif
	#ifdef END
		const float bloomAmount = BLOOM_END_AMOUNT;
	#endif
	
	bloomAddition *= 1.0 - 0.75 * getLum(color);
	color += bloomAddition * bloomAmount * 0.5;
	
}
