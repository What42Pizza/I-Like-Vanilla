void processOpaqueMaterials(uint materialId) {
	
	uint encodedData = materialId >> 10u;
	// foliage normals
	if ((encodedData & 1u) == 1u && encodedData > 1u) normal = encodeNormal(gl_NormalMatrix * vec3(0.0, 1.0, 0.0));
	
}
