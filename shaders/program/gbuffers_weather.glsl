in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
flat in_out vec3 normal;
in_out vec3 viewPos;

flat in_out vec3 shadowcasterLight;



#ifdef FSH

#include "/lib/lighting/simple_fsh_lighting.glsl"

void main() {
	
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	color.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	
	doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, 0.3, viewPos, normal);
	
	#if TEMPORAL_FILTER_ENABLED == 1
		color.a = mix(1.0, color.a, 16.0 / (16.0 + length(viewPos))) * uint(color.a > 0.0);
	#endif
	
	
	/* DRAWBUFFERS:0 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.0, 0.5, 1.0, 1.0);
	#endif
	color.rgb *= 0.5;
	gl_FragData[0] = color;
	
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
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal = gl_NormalMatrix * gl_Normal;
	
	shadowcasterLight = getShadowcasterLight();
	
	vec3 playerPos = gl_Vertex.xyz;
	
	float horizontalAmount = playerPos.y * WEATHER_HORIZONTAL_AMOUNT * 0.5;
	playerPos.xz *= 2.0;
	playerPos.x += horizontalAmount;
	horizontalAmount *= 0.5;
	playerPos.z += horizontalAmount;
	
	float worldY = playerPos.y + cameraPosition.y;
	bool isBottom = playerPos.y < 0.0;
	float maxY = cloudHeight + 1.0 - uint(isBottom) * 10.0;
	worldY = min(worldY, maxY);
	playerPos.y = worldY - cameraPosition.y;
	
	viewPos = mat3(gbufferModelView) * playerPos;
	#if ISOMETRIC_RENDERING_ENABLED == 1
		gl_Position = projectIsometric(playerPos);
	#else
		gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(playerPos, 1.0);
	#endif
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	glcolor = gl_Color;
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
