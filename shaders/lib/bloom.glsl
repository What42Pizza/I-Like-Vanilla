#include "/utils/depth.glsl"

const bool colortex4MipmapEnabled = true;



void addBloom(inout vec3 color) {
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float blockDepth = toBlockDepth(depth);
	float sizeMult = inversesqrt(blockDepth + 1.0) * BLOOM_SIZE * 0.25;
	
	#if BSL_MODE == 1
		sizeMult *= 3.0;
	#endif
	
	//// good values: 21.0015, 22.001, 0.02
	//#ifdef GRADIENT_NOISE_SPEED
	//	#undef GRADIENT_NOISE_SPEED
	//#endif
	//#define GRADIENT_NOISE_SPEED 21.002
	//#include "/utils/var_gradient_noise.glsl"
	
	//float dither = bayer64(gl_FragCoord.xy);
	//dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	
	float noise = texelFetch(noisetex, (texelcoord + frameCounter * 17) & 127, 0).r;
	
	float randomAngle = (noise - 0.5) * 2.0 * PI;
	mat2 rotationMatrix;
	rotationMatrix[0] = vec2(cos(randomAngle) * invAspectRatio, -sin(randomAngle)) * sizeMult;
	rotationMatrix[1] = vec2(sin(randomAngle) * invAspectRatio,  cos(randomAngle)) * sizeMult;
	
	#if BLOOM_QUALITY == 1
		vec2 texcoord = texcoord;
		noise = texelFetch(noisetex, (texelcoord + frameCounter * 17 + 32) & 127, 0).b;
		texcoord.x += (noise - 0.5) * 0.1 * sizeMult * invAspectRatio;
		noise = texelFetch(noisetex, (texelcoord + frameCounter * 17 + 64) & 127, 0).b;
		texcoord.y += (noise - 0.5) * 0.1 * sizeMult;
	#endif
	
	// these values were generated with https://github.com/What42Pizza/Small-Rust-Programs/tree/master/point-distribution
	vec3 bloomAddition = vec3(0.0);
	#if BLOOM_QUALITY == 1
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.153,  0.067), 3).rgb * (2.0 * 0.977 / 4.362);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.236, -0.235), 3).rgb * (2.0 * 0.910 / 4.362);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.442,  0.234), 3).rgb * (2.0 * 0.809 / 4.362);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.280, -0.605), 3).rgb * (2.0 * 0.685 / 4.362);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.186,  0.812), 3).rgb * (2.0 * 0.554 / 4.362);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.994,  0.113), 3).rgb * (2.0 * 0.427 / 4.362);
	#elif BLOOM_QUALITY == 2
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.096,  0.028), 3).rgb * (2.0 * 0.992 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.082, -0.183), 3).rgb * (2.0 * 0.967 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.278,  0.113), 3).rgb * (2.0 * 0.926 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.071,  0.394), 3).rgb * (2.0 * 0.873 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.450, -0.219), 3).rgb * (2.0 * 0.809 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.507,  0.321), 3).rgb * (2.0 * 0.736 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.084, -0.695), 3).rgb * (2.0 * 0.659 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.652, -0.464), 3).rgb * (2.0 * 0.580 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.236,  0.868), 3).rgb * (2.0 * 0.502 / 7.472);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.938,  0.347), 3).rgb * (2.0 * 0.427 / 7.472);
	#elif BLOOM_QUALITY == 3
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.057,  0.025), 3).rgb * (2.0 * 0.997 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.088, -0.088), 3).rgb * (2.0 * 0.987 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.178,  0.058), 3).rgb * (2.0 * 0.971 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.080, -0.237), 3).rgb * (2.0 * 0.948 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.103,  0.295), 3).rgb * (2.0 * 0.920 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.362, -0.098), 3).rgb * (2.0 * 0.887 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.159,  0.408), 3).rgb * (2.0 * 0.850 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.419,  0.273), 3).rgb * (2.0 * 0.809 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.308, -0.471), 3).rgb * (2.0 * 0.764 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.600, -0.176), 3).rgb * (2.0 * 0.717 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.099, -0.680), 3).rgb * (2.0 * 0.669 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.665,  0.347), 3).rgb * (2.0 * 0.620 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.655, -0.481), 3).rgb * (2.0 * 0.571 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.375,  0.791), 3).rgb * (2.0 * 0.522 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.923,  0.163), 3).rgb * (2.0 * 0.474 / 12.133);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.313,  0.950), 3).rgb * (2.0 * 0.427 / 12.133);
	#elif BLOOM_QUALITY == 4
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.028,  0.031), 3).rgb * (2.0 * 0.999 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.079,  0.026), 3).rgb * (2.0 * 0.994 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.108, -0.062), 3).rgb * (2.0 * 0.987 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.062, -0.155), 3).rgb * (2.0 * 0.977 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.018,  0.208), 3).rgb * (2.0 * 0.964 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.214,  0.129), 3).rgb * (2.0 * 0.948 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.284, -0.068), 3).rgb * (2.0 * 0.930 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.127, -0.308), 3).rgb * (2.0 * 0.910 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.281,  0.248), 3).rgb * (2.0 * 0.887 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.385, -0.158), 3).rgb * (2.0 * 0.863 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.263, -0.376), 3).rgb * (2.0 * 0.836 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.182,  0.466), 3).rgb * (2.0 * 0.809 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.501,  0.207), 3).rgb * (2.0 * 0.779 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.581,  0.056), 3).rgb * (2.0 * 0.749 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.014, -0.625), 3).rgb * (2.0 * 0.717 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.271,  0.609), 3).rgb * (2.0 * 0.685 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.652, -0.277), 3).rgb * (2.0 * 0.653 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.417, -0.623), 3).rgb * (2.0 * 0.620 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.748, -0.260), 3).rgb * (2.0 * 0.587 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.712,  0.433), 3).rgb * (2.0 * 0.554 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.437, -0.758), 3).rgb * (2.0 * 0.522 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.104,  0.911), 3).rgb * (2.0 * 0.490 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.641,  0.712), 3).rgb * (2.0 * 0.458 / 18.345);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.971,  0.237), 3).rgb * (2.0 * 0.427 / 18.345);
	#elif BLOOM_QUALITY == 5
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.032, -0.172), 3).rgb * (2.0 * 0.999 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.142,  0.141), 3).rgb * (2.0 * 0.997 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.190,  0.120), 3).rgb * (2.0 * 0.993 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.045,  0.246), 3).rgb * (2.0 * 0.988 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.253, -0.109), 3).rgb * (2.0 * 0.982 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.132, -0.269), 3).rgb * (2.0 * 0.974 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.189, -0.264), 3).rgb * (2.0 * 0.965 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.342,  0.076), 3).rgb * (2.0 * 0.954 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.180,  0.329), 3).rgb * (2.0 * 0.942 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.344, -0.204), 3).rgb * (2.0 * 0.929 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.425, -0.007), 3).rgb * (2.0 * 0.915 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.115, -0.435), 3).rgb * (2.0 * 0.900 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.425,  0.212), 3).rgb * (2.0 * 0.883 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.285,  0.411), 3).rgb * (2.0 * 0.866 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.152, -0.502), 3).rgb * (2.0 * 0.848 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.063,  0.546), 3).rgb * (2.0 * 0.828 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.421, -0.392), 3).rgb * (2.0 * 0.809 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.462,  0.383), 3).rgb * (2.0 * 0.788 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.212,  0.588), 3).rgb * (2.0 * 0.767 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.629, -0.163), 3).rgb * (2.0 * 0.745 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.657,  0.155), 3).rgb * (2.0 * 0.723 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.544, -0.441), 3).rgb * (2.0 * 0.701 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.699, -0.194), 3).rgb * (2.0 * 0.678 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.348, -0.664), 3).rgb * (2.0 * 0.655 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.018, -0.775), 3).rgb * (2.0 * 0.632 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.787,  0.143), 3).rgb * (2.0 * 0.608 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.646,  0.513), 3).rgb * (2.0 * 0.585 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.383, -0.759), 3).rgb * (2.0 * 0.562 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2(-0.347,  0.803), 3).rgb * (2.0 * 0.539 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.747, -0.501), 3).rgb * (2.0 * 0.516 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.525,  0.762), 3).rgb * (2.0 * 0.493 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.077,  0.947), 3).rgb * (2.0 * 0.471 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.974, -0.054), 3).rgb * (2.0 * 0.449 / 26.110);
		bloomAddition += texture2DLod(BLOOM_TEXTURE, texcoord + rotationMatrix * vec2( 0.883,  0.470), 3).rgb * (2.0 * 0.427 / 26.110);
	#endif
	
	//bloomAddition += 0.25 * dFdx(bloomAddition) * (1 - ((int(gl_FragCoord.x) & 1) << 1));
	//bloomAddition += 0.25 * dFdy(bloomAddition) * (1 - ((int(gl_FragCoord.y) & 1) << 1));
	
	#ifdef OVERWORLD
		const float bloomAmount = BLOOM_AMOUNT;
	#endif
	#ifdef NETHER
		const float bloomAmount = BLOOM_NETHER_AMOUNT;
	#endif
	#ifdef END
		const float bloomAmount = BLOOM_END_AMOUNT;
	#endif
	
	float lum = getLum(color);
	bloomAddition *= 1.0 - lum;
	color += bloomAddition * bloomAmount * 0.5;
	
}
