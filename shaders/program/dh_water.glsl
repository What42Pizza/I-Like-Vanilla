#undef SHADOWS_ENABLED
#undef HANDHELD_LIGHT_ENABLED
#define HANDHELD_LIGHT_ENABLED 0

in_out vec4 glcolor;
in_out vec2 lmcoord;
in_out vec3 viewPos;
in_out vec3 playerPos;
flat in_out vec3 normal;
flat in_out int dhBlock;

flat in_out vec3 shadowcasterLight;



#ifdef FSH

#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"

#include "/utils/screen_to_view.glsl"
#if WAVING_WATER_SURFACE_ENABLED == 1
	#include "/lib/simplex_noise.glsl"
#endif

void main() {
	
	float dither = bayer64(gl_FragCoord.xy);
	#if TEMPORAL_FILTER_ENABLED == 1
		dither = fract(dither + 1.61803398875 * mod(float(frameCounter), 3600.0));
	#endif
	float lengthCylinder = max(length(playerPos.xz), abs(playerPos.y));
	if (lengthCylinder < far - 10.0 - 8.0 * dither) discard;
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	if (depth < 1.0 && length(playerPos) > toLinearDepth(depth) * far) discard;
	
	
	vec4 color = glcolor;
	
	
	// add noise for fake texture
	float worldScale = 300.0 / length(playerPos);
	uvec3 noisePos = uvec3(ivec3((playerPos + cameraPosition) * ceil(worldScale) + 0.5));
	uint noise = randomizeUint(noisePos.x) ^ randomizeUint(noisePos.y) ^ randomizeUint(noisePos.z);
	color.rgb += 0.03 * randomFloat(noise);
	color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));
	
	
	float reflectiveness = clamp(0.5 + 3.0 * (getLum(color.rgb) * 1.5 - 0.5), 0.0, 1.0);
	
	
	#if WAVING_WATER_SURFACE_ENABLED == 1
		vec3 normal = normal;
	#endif
	
	if (dhBlock == DH_BLOCK_WATER) {
		
		color.rgb *= 1.1;
		
		color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 0.8);
		color.rgb = mix(color.rgb, WATER_COLOR, WATER_COLOR_AMOUNT);
		
		vec3 viewDir = normalize(viewPos);
		float fresnel = -dot(normal, viewDir);
		
		#if WAVING_WATER_SURFACE_ENABLED == 1
			vec2 noisePos = (playerPos.xz + cameraPosition.xz) / WAVING_WATER_SCALE * 0.25;
			float wavingSurfaceAmount = mix(WAVING_WATER_SURFACE_AMOUNT_UNDERGROUND, WAVING_WATER_SURFACE_AMOUNT_SURFACE, lmcoord.y) * fresnel * 0.125;
			if (wavingSurfaceAmount > 0.00001) {
				float fresnelMult = mix(WAVING_WATER_FRESNEL_UNDERGROUND * 0.55, WAVING_WATER_FRESNEL_SURFACE * 0.55, lmcoord.y);
				float frameTimeCounter = frameTimeCounter * WAVING_WATER_SPEED;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				noisePos += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				//noisePos += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25 * 0.18;
				vec3 normalForFresnel = vec3(0.0, 1.0, 0.0);
				normalForFresnel.xz += (texture2D(noisetex, noisePos * 0.03125 + frameTimeCounter * vec2( 0.01,  0.01)).br * 2.0 - 1.0) * 0.4;
				//normalForFresnel.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2( 0.01, -0.01)).br * 2.0 - 1.0) * 0.25;
				//normalForFresnel.xz += (texture2D(noisetex, noisePos * 0.0625  + frameTimeCounter * vec2(-0.01,  0.01)).br * 2.0 - 1.0) * 0.25;
				//normalForFresnel.xz *= wavingSurfaceAmount;
				normalForFresnel = mat3(gbufferModelView) * normalize(normalForFresnel);
				fresnel = dot(normalForFresnel, viewDir); // note: there should be made negative, but instead the next line does 1+fresnel instead of 1-fresnel
				color.rgb *= 1.0 + (fresnel + 0.5) * fresnelMult;
			}
		#endif
		
		color.a = 1.0 - WATER_TRANSPARENCY_DEEP;
		
		color.a *= 1.0 + fresnel * 0.125;
		
	}
	
	
	float specularness = 0.3;
	if (dhBlock == DH_BLOCK_WATER) {
		reflectiveness = mix(WATER_REFLECTION_AMOUNT_UNDERGROUND, WATER_REFLECTION_AMOUNT_SURFACE, lmcoord.y) * max(color.a * 1.3, 1.0);
		specularness = 0.99;
	}
	
	
	// main lighting
	float _shadowBrightness;
	doFshLighting(color.rgb, _shadowBrightness, lmcoord.x, lmcoord.y, specularness, 0.0, viewPos, normal, gl_FragCoord.z);
	
	
	/* DRAWBUFFERS:03 */
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(reflectiveness, 0.0),
		encodeNormal(normal)
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/utils/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	glcolor = gl_Color;
	glcolor.rgb = mix(glcolor.rgb, glcolor.rgb * glcolor.rgb * (3.0 - 2.0 * glcolor.rgb), TEXTURE_CONTRAST * 1.0);
	glcolor.rgb = mix(vec3(getLum(glcolor.rgb)), glcolor.rgb, 1.05 - TEXTURE_CONTRAST * 0.25);
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	normal = gl_NormalMatrix * gl_Normal;
	dhBlock = dhMaterialId;
	
	viewPos = transform(gl_ModelViewMatrix, gl_Vertex.xyz);
	playerPos = transform(gbufferModelViewInverse, viewPos);
	if (dhBlock == DH_BLOCK_WATER) {
		playerPos.y -= 0.11213;
	}
	shadowcasterLight = getShadowcasterLight();
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * gbufferModelView * startMat(playerPos);
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
