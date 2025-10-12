#ifdef FIRST_PASS
	
	in_out vec2 texcoord;
	in_out vec2 lmcoord;
	in_out vec4 glcolor;
	flat in_out vec2 normal;
	
#endif





#ifdef FSH

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord);
	color.rgb = (color.rgb - 0.5) * (1.0 + TEXTURE_CONTRAST * 0.5) + 0.5;
	color.rgb = mix(vec3(getLum(color.rgb)), color.rgb, 1.0 - TEXTURE_CONTRAST * 0.45);
	color.rgb = clamp(color.rgb, 0.0, 1.0);
	color *= glcolor;
	
	
	// hurt flash, creeper flash, etc
	#include "/import/entityColor.glsl"
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color.rgb *= 1.0 + (1.0 - max(lmcoord.x, lmcoord.y)) * entityColor.a;
	
	
	/* DRAWBUFFERS:02 */
	color.rgb *= 0.5;
	gl_FragData[0] = vec4(color);
	gl_FragData[1] = vec4(
		packVec2(lmcoord.x * 0.25, lmcoord.y * 0.25),
		packVec2(normal),
		packVec2(0.0, 0.3),
		floor(glcolor.a + 0.1)
	);
	
}

#endif





#ifdef VSH

#include "/lib/lighting/vsh_lighting.glsl"

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
	glcolor = gl_Color;
	normal = encodeNormal(gl_NormalMatrix * gl_Normal);
	
	vec3 viewPos = mat3(gl_ModelViewMatrix) * gl_Vertex.xyz;
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 1
		#include "/import/gbufferModelViewInverse.glsl"
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		gl_Position = projectIsometric(playerPos  ARGS_IN);
	#else
		gl_Position = ftransform();
	#endif
	
	
	#if ISOMETRIC_RENDERING_ENABLED == 0
		if (gl_Position.z < -5.0) return; // simple but effective(?) optimization
	#endif
	
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy  ARGS_IN);
	#endif
	
	
	doVshLighting(length(viewPos)  ARGS_IN);
	
}

#endif
