in_out vec2 texcoord;
in_out vec2 lmcoord;
in_out vec4 glcolor;
flat in_out vec3 normal;
in_out vec3 viewPos;



#ifdef FSH

#include "/lib/lighting/simple_fsh_lighting.glsl"

void main() {
	vec4 color = texture2D(MAIN_TEXTURE, texcoord) * glcolor;
	
	doSimpleFshLighting(color.rgb, lmcoord.x, lmcoord.y, 0.3, viewPos, normal);
	
	/* DRAWBUFFERS:8 */
	#if DO_COLOR_CODED_GBUFFERS == 1
		color = vec4(0.0, 0.5, 1.0, 1.0);
	#endif
	gl_FragData[0] = color;
	
}

#endif



#ifdef VSH

#include "/utils/projections.glsl"
#include "/lib/lighting/vsh_lighting.glsl"

#if TAA_ENABLED == 1
	#include "/lib/taa_jitter.glsl"
#endif

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal = gl_NormalMatrix * gl_Normal;
	
	vec3 playerPos = gl_Vertex.xyz;
	playerPos.x += bayer16(playerPos.xz);
	
	float horizontalAmount = playerPos.y * WEATHER_HORIZONTAL_AMOUNT;
	playerPos *= 2.0;
	playerPos.x += horizontalAmount;
	horizontalAmount *= 0.5;
	playerPos.z += horizontalAmount;
	
	float worldY = playerPos.y + cameraPosition.y;
	bool isBottom = playerPos.y < 0.0;
	float maxY = cloudHeight + 1.0 - float(isBottom) * 10.0;
	worldY = min(worldY, maxY);
	playerPos.y = worldY - cameraPosition.y;
	
	viewPos = mat3(gbufferModelView) * playerPos;
	gl_Position = viewToNdc(viewPos);
	
	#if TAA_ENABLED == 1
		doTaaJitter(gl_Position.xy);
	#endif
	
	glcolor = gl_Color;
	
	const float distSlope  = 2.0;
	const float alphaClose = 0.75;
	const float alphaFar   = 1.25;
	glcolor.a = alphaFar - (alphaFar - alphaClose) * distSlope / (length(playerPos.xz) + distSlope);
	glcolor.a *= 1.0 - WEATHER_TRANSPARENCY;
	
	
	doVshLighting(lmcoord, viewPos, normal);
	
}

#endif
