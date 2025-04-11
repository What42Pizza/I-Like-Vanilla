#ifdef FIRST_PASS
	in_out vec2 texcoord;
	flat in_out vec3 shadowcasterColor;
#endif





#ifdef FSH



#include "/lib/lighting/fsh_lighting.glsl"

#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/fog/getFogAmount.glsl"
	#include "/lib/fog/applyFog.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"

#if OUTLINES_ENABLED == 1
	#include "/lib/outlines.glsl"
#endif



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb;
	vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
	vec2 lmcoord = unpackVec2(data.x) * 4.0;
	vec3 normal = decodeNormal(unpackVec2(data.y));
	
	
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	float linearDepth = toLinearDepth(depth  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float linearDhDepth = toLinearDepthDh(dhDepth  ARGS_IN);
	#endif
	
	
	
	// ======== OUTLINES ======== //
	
	#if OUTLINES_ENABLED == 1
		color *= 1.0 - getOutlineAmount(ARG_IN);
	#endif
	
	
	#ifdef DISTANT_HORIZONS
		bool isNonSky = !depthIsSky(linearDepth) || !depthIsSky(linearDhDepth);
	#else
		bool isNonSky = !depthIsSky(linearDepth);
	#endif
	if (isNonSky) {
		
		
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		doFshLighting(color, lmcoord.x, lmcoord.y, viewPos, normal  ARGS_IN);
		
		
		#if BORDER_FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogAmount = getFogAmount(playerPos  ARGS_IN);
			applyFog(color, fogAmount  ARGS_IN);
		#endif
		
		
		#if SSAO_ENABLED == 1
			float aoFactor = getAoFactor(ARG_IN);
			color *= 1.0 - aoFactor * AO_AMOUNT;
		#endif
		
		
	}
	
	
	
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

#include "/utils/getShadowcasterColor.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	shadowcasterColor = getShadowcasterColor(ARG_IN);
}

#endif
