#undef HANDHELD_LIGHT_ENABLED
#define HANDHELD_LIGHT_ENABLED 0

in_out vec2 lmcoord;
in_out vec3 glcolor;
flat in_out vec2 encodedNormal;
in_out vec3 playerPos;
flat in_out int dhBlock;



#ifdef FSH

void main() {
	
	//float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	//if (lengthCylinder < far - 20.0) discard;
	
	vec3 color = glcolor;
	
	
	// add noise for fake texture
	float worldScale = 300.0 / length(playerPos);
	uvec3 noisePos = uvec3(ivec3((playerPos + cameraPosition) * ceil(worldScale) + 0.5));
	randomizeUint(noisePos.x);
	randomizeUint(noisePos.y);
	randomizeUint(noisePos.z);
	uint noise = noisePos.x ^ noisePos.y ^ noisePos.z;
	color += 0.03 * randomFloat(noise);
	//color = clamp(color, vec3(0.0), vec3(1.0));
	
	
	/* DRAWBUFFERS:02 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(0.0, float(dhBlock == DH_BLOCK_LEAVES)),
		encodedNormal
	);
	
}

#endif





#ifdef VSH

#define PROJECTION_MATRIX gl_ProjectionMatrix
#include "/utils/projections.glsl"
#include "/lib/lighting/vsh_lighting.glsl"

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
	
	
	if (dhMaterialId == DH_BLOCK_LEAVES || dhMaterialId == DH_BLOCK_GRASS) {
		glcolor = mix(vec3(getLum(glcolor)), glcolor, FOLIAGE_SATURATION);
		glcolor *= vec3(FOLIAGE_TINT_RED, FOLIAGE_TINT_GREEN, FOLIAGE_TINT_BLUE);
		#if SNOWY_TWEAKS_ENABLED == 1
			if (inSnowyBiome > 0.0) {
				float snowiness = (0.9 + 0.1 * wetness) * inSnowyBiome / (1.0 + 0.00390625 * length(playerPos)) * lmcoord.y * lmcoord.y;
				glcolor = mix(glcolor, vec3(1.0, 1.05, 1.2), snowiness);
				glcolor *= 1.0 + 0.4 * snowiness;
			}
		#endif
	}
	if (dhMaterialId == DH_BLOCK_LEAVES) glcolor *= 1.15;// + 0.3 * (gl_Normal.y * 0.5 - 0.5);
	
	glcolor = glcolor - (4.0 / 27.0) * glcolor * glcolor * glcolor;
	float m = getLum(glcolor);
	m = m * m * (3.0 - 2.0 * m);
	glcolor *= 1.0 - TEXTURE_CONTRAST * 0.125 + m * TEXTURE_CONTRAST * 0.25;
	color.rgb = color.rgb * (1.0 + TEXTURE_CONTRAST_2 * 0.025) - TEXTURE_CONTRAST_2 * 0.025;
	
	
	gl_Position = viewToNdc(viewPos);
	gl_Position = ftransform();
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, glcolor, viewPos, normal, gl_Normal);
	
}

#endif
