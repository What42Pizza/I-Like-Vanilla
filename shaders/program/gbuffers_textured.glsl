in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
flat in_out vec3 normal;
in_out vec3 viewPos;
in_out float blockDepth;

flat in_out vec3 shadowcasterLight;



#ifdef FSH

#include "/lib/lighting/simple_fsh_lighting.glsl"

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	
	
	// hide nearby particles
	if (color.a > 0.99) {
		float transparency = percentThrough(blockDepth, 0.5, 1.2);
		color.a *= (transparency - 1.0) * NEARBY_PARTICLE_TRANSPARENCY + 1.0;
	}
	
	
	// main lighting
	doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, 0.3, viewPos, normal);
	
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		pack_2x8(lmcoord),
		pack_2x8(0.0, 0.3),
		normal
	);
	
}

#endif



#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"
#include "/utils/getShadowcasterLight.glsl"

#if ISOMETRIC_RENDERING_ENABLED == 1
	#include "/lib/isometric.glsl"
#endif
#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	adjustLmcoord(lmcoord);
	lmcoord = min(lmcoord + 0.05, 1.0);
	glcolor = gl_Color;
	glcolor.a = sqrt(glcolor.a);
	normal = gl_NormalMatrix * gl_Normal;
	
	viewPos = mat3(gl_ModelViewMatrix) * gl_Vertex.xyz;
	blockDepth = length(viewPos.xyz);
	
	shadowcasterLight = getShadowcasterLight();
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = ftransform();
	#endif
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -1.0) return; // simple but effective optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	
	doVshLighting(blockDepth);
	
}

#endif
