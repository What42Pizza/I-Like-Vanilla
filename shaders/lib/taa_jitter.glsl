void doTaaJitter(inout vec2 pos  ARGS_OUT) {
	#include "/import/taaOffset.glsl"
	vec2 offset = taaOffset;
	//#define JITTER_SLOPE_FIX
	//#if defined JITTER_SLOPE_FIX && !(defined SHADER_DH_TERRAIN || defined SHADER_DH_WATER)
	//	vec3 viewDir = normalize(mat3(gl_ModelViewMatrix) * gl_Vertex.xyz);
	//	float offsetMult = dot(gl_NormalMatrix * gl_Normal, -viewDir);
	//	offset *= clamp(offsetMult * 8.0 - 0.15, 0.0, 1.0);
	//#endif
	#if ISOMETRIC_RENDERING_ENABLED == 1
		pos += offset * 0.7;
	#else
		pos += offset * gl_Position.w;
	#endif
}
