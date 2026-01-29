in_out vec2 texcoord;



#ifdef FSH

void main() {
	vec4 color = texture2D(texture, texcoord);
	vec2 lmcoord;
	float ao;
	vec4 overlayColor;
	clrwl_computeFragment(color, color, lmcoord, ao, overlayColor);
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}

#endif



#ifdef VSH

#if COLORED_LIGHTING_ENABLED == 1
	#include "/lib/colored_lighting/updateVoxelIds.glsl"
#endif

void main() {
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	
	#if COLORED_LIGHTING_ENABLED == 1
		uint encodedData = uint(max(mc_Entity.x - (1u << 13u), 0) + (1u << 13u));
		uint materialId = encodedData;
		materialId &= (1u << 10u) - 1u;
	#endif
	
	#if COLORED_LIGHTING_ENABLED == 1
		if (gl_VertexID % 4 == 0) {
			updateVoxelIds(playerPos, materialId);
		}
	#endif
	
	#if COLORED_LIGHTING_ENABLED == 1
		gl_Position = shadowProjection * shadowModelView * vec4(playerPos, 1.0);
	#else
		gl_Position = ftransform();
	#endif
	
	gl_Position.xyz = distort(gl_Position.xyz);
	
}

#endif
