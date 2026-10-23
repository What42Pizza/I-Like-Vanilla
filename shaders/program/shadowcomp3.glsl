// workgroup size (always 8x8x8)
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

// number of workgroups
#if COLORED_LIGHTING_DIST == 32
	const ivec3 workGroups = ivec3(4, 3, 4);
#elif COLORED_LIGHTING_DIST == 48
	const ivec3 workGroups = ivec3(6, 4, 6);
#elif COLORED_LIGHTING_DIST == 64
	const ivec3 workGroups = ivec3(8, 6, 8);
#elif COLORED_LIGHTING_DIST == 96
	const ivec3 workGroups = ivec3(12, 9, 12);
#elif COLORED_LIGHTING_DIST == 128
	const ivec3 workGroups = ivec3(16, 12, 16);
#elif COLORED_LIGHTING_DIST == 192
	const ivec3 workGroups = ivec3(24, 18, 24);
#elif COLORED_LIGHTING_DIST == 256
	const ivec3 workGroups = ivec3(32, 24, 32);
#elif COLORED_LIGHTING_DIST == 384
	const ivec3 workGroups = ivec3(48, 36, 48);
#elif COLORED_LIGHTING_DIST == 512
	const ivec3 workGroups = ivec3(64, 48, 64);
#else
	const ivec3 workGroups = ivec3(8, 6, 8);
#endif



uniform usampler3D voxelIdsSampler;
uniform sampler3D lightFloodfill1Sampler;
uniform sampler3D lightFloodfill2Sampler;
#extension GL_ARB_shader_image_load_store : enable
writeonly uniform image3D lightFloodfill1;
writeonly uniform image3D lightFloodfill2;



#include "/lib/colored_lighting/updateFloodFill.glsl"



void main() {
	if (frameCounter % 2 == 0) {
		updateFloodFill(lightFloodfill1Sampler, lightFloodfill2, false);
	} else {
		updateFloodFill(lightFloodfill2Sampler, lightFloodfill1, false);
	}
}
