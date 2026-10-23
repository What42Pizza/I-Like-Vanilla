#include "/lib/colored_lighting/coloredLightingUtils.glsl"



vec3 sampleColoredLighting(vec3 voxelPos) {
	if (frameCounter % 2 == 0) {
		vec3 sample_lll = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 0, 0), 0).rgb;
		vec3 sample_hll = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 0, 0), 0).rgb;
		vec3 sample_lhl = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 1, 0), 0).rgb;
		vec3 sample_hhl = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 1, 0), 0).rgb;
		vec3 sample_llh = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 0, 1), 0).rgb;
		vec3 sample_hlh = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 0, 1), 0).rgb;
		vec3 sample_lhh = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 1, 1), 0).rgb;
		vec3 sample_hhh = texelFetch(lightFloodfill2Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 1, 1), 0).rgb;
		vec3 voxelPosFract = fract(voxelPos - 0.5);
		vec3 sample_ll = mix(sample_lll, sample_hll, voxelPosFract.x);
		vec3 sample_hl = mix(sample_lhl, sample_hhl, voxelPosFract.x);
		vec3 sample_lh = mix(sample_llh, sample_hlh, voxelPosFract.x);
		vec3 sample_hh = mix(sample_lhh, sample_hhh, voxelPosFract.x);
		vec3 sample_l = mix(sample_ll, sample_hl, voxelPosFract.y);
		vec3 sample_h = mix(sample_lh, sample_hh, voxelPosFract.y);
		vec3 final_sample = mix(sample_l, sample_h, voxelPosFract.z);
		
		vec3 corrected = 1.0 - log2(final_sample)/log2(0.78) / 15.0;
		return mix(final_sample, clamp(corrected, 0.0, 1.0), 0.9) * 1.1;
	} else {
		vec3 sample_lll = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 0, 0), 0).rgb;
		vec3 sample_hll = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 0, 0), 0).rgb;
		vec3 sample_lhl = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 1, 0), 0).rgb;
		vec3 sample_hhl = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 1, 0), 0).rgb;
		vec3 sample_llh = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 0, 1), 0).rgb;
		vec3 sample_hlh = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 0, 1), 0).rgb;
		vec3 sample_lhh = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(0, 1, 1), 0).rgb;
		vec3 sample_hhh = texelFetch(lightFloodfill1Sampler, ivec3(floor(voxelPos - 0.5)) + ivec3(1, 1, 1), 0).rgb;
		vec3 voxelPosFract = fract(voxelPos - 0.5);
		vec3 sample_ll = mix(sample_lll, sample_hll, voxelPosFract.x);
		vec3 sample_hl = mix(sample_lhl, sample_hhl, voxelPosFract.x);
		vec3 sample_lh = mix(sample_llh, sample_hlh, voxelPosFract.x);
		vec3 sample_hh = mix(sample_lhh, sample_hhh, voxelPosFract.x);
		vec3 sample_l = mix(sample_ll, sample_hl, voxelPosFract.y);
		vec3 sample_h = mix(sample_lh, sample_hh, voxelPosFract.y);
		vec3 final_sample = mix(sample_l, sample_h, voxelPosFract.z);
		
		vec3 corrected = 1.0 - log2(final_sample)/log2(0.78) / 15.0;
		return mix(final_sample, clamp(corrected, 0.0, 1.0), 0.9) * 1.1;
	}
}
