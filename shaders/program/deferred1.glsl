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
	#include "/lib/borderFog/getBorderFogAmount.glsl"
	#include "/lib/borderFog/applyBorderFog.glsl"
#endif
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"

#if OUTLINES_ENABLED == 1
	#include "/lib/outlines.glsl"
#endif



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb;
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	//if (depthIsHand(depth)) depth += 0.38;
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
	#endif
	
	
	
	// ======== OUTLINES ======== //
	
	#if OUTLINES_ENABLED == 1
		color *= 1.0 - getOutlineAmount(ARG_IN);
	#endif
	
	
	
	#ifdef DISTANT_HORIZONS
		bool isNonSky = depth != 1.0 || dhDepth != 1.0;
	#else
		bool isNonSky = depth != 1.0;
	#endif
	if (isNonSky) {
		
		
		vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		vec2 lmcoord = unpackVec2(data.x) * 4.0;
		float specular_amount = unpackVec2(data.z).y;
		vec3 normal = decodeNormal(unpackVec2(data.y));
		vec3 viewPos = screenToView(vec3(texcoord, depth + (depthIsHand(depth) ? 0.38 : 0.0))  ARGS_IN);
		doFshLighting(color, lmcoord.x, lmcoord.y, specular_amount, viewPos, normal  ARGS_IN);
		
		
		#if BORDER_FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
			float fogAmount = getBorderFogAmount(playerPos  ARGS_IN);
			applyBorderFog(color, viewPos, fogAmount  ARGS_IN);
		#endif
		
		
		#if SSAO_ENABLED == 1
			if (!depthIsHand(depth)) {
				float aoFactor = getAoFactor(depth, length(viewPos)  ARGS_IN);
				aoFactor *= 1.0 - 0.7 * getColorLum(color);
				color *= 1.0 - aoFactor * AO_AMOUNT;
				//color = vec3(aoFactor);
			}
		#endif
		
		
	} else {
		#ifdef NETHER
			vec3 viewPos = screenToView(vec3(texcoord, 1.0)  ARGS_IN);
			color = getSkyColor(normalize(viewPos), true  ARGS_IN);
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
