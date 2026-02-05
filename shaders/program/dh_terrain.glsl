#undef HANDHELD_LIGHT_ENABLED
#define HANDHELD_LIGHT_ENABLED 0

in_out vec2 lmcoord;
in_out vec3 glcolor;
flat in_out vec2 encodedNormal;
in_out vec3 playerPos;
flat in_out int dhBlock;



#ifdef FSH

void main() {
	
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	if (lengthCylinder < far - 20.0) discard;
	
	vec3 color = glcolor;
	
	
	// add noise for fake texture
	float worldScale = 300.0 / length(playerPos);
	uvec3 noisePos = uvec3(ivec3((playerPos + cameraPosition) * ceil(worldScale) + 0.5));
	uint noise = randomizeUint(noisePos.x) ^ randomizeUint(noisePos.y) ^ randomizeUint(noisePos.z);
	color += 0.03 * randomFloat(noise);
	color = clamp(color, vec3(0.0), vec3(1.0));
	
	
	/* DRAWBUFFERS:02 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(0.0, 0.3),
		encodedNormal
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	glcolor = gl_Color.rgb;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	vec3 normal = gl_NormalMatrix * gl_Normal;
	encodedNormal = encodeNormal(normal);
	vec3 viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	dhBlock = dhMaterialId;
	
	
	glcolor *= 0.98;
	if (dhMaterialId == DH_BLOCK_LEAVES) {
		glcolor = mix(vec3(getLum(glcolor)), glcolor, FOLIAGE_SATURATION * 0.95);
		glcolor *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE) * 1.05;
	}
	color.rgb = mix(color.rgb, color.rgb * color.rgb * (3.0 - 2.0 * color.rgb), TEXTURE_CONTRAST * 1.0);
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.05 - TEXTURE_CONTRAST * 0.25);
	if (dhMaterialId != DH_BLOCK_LEAVES) glcolor *= 1.0 + 0.3 * (gl_Normal.y * 0.5 - 0.5);
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * startMat(viewPos);
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
