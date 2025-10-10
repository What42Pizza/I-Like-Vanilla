#ifdef FIRST_PASS
	in_out vec2 texcoord;
	flat in_out vec3 shadowcasterLight;
#endif





#ifdef FSH



#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"

#if OUTLINES_ENABLED == 1
	#include "/lib/outlines.glsl"
#endif
#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/borderFogAmount.glsl"
#endif
#ifndef END
	#include "/utils/getSkyColor.glsl"
#endif



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth + (depthIsHand(depth) ? 0.38 : 0.0))  ARGS_IN);
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 dhViewPos = screenToViewDh(vec3(texcoord, dhDepth)  ARGS_IN);
		if (dhViewPos.z > viewPos.z) viewPos = dhViewPos;
	#endif
	
	#include "/import/gbufferModelViewInverse.glsl"
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	#ifdef DISTANT_HORIZONS
		float skyAmount = float(depth == 1.0 && dhDepth == 1.0);
	#else
		#if BORDER_FOG_ENABLED == 1
			float skyAmount = getBorderFogAmount(playerPos  ARGS_IN);
		#else
			float skyAmount = float(depth == 1.0);
		#endif
	#endif
	
	
	#if OUTLINES_ENABLED == 1
		color *= 1.0 - getOutlineAmount(ARG_IN);
	#endif
	
	
	vec3 skyColor = vec3(0.0);
	if (skyAmount > 0.0) {
		#ifdef END
			skyColor = texelFetch(SKY_OBJECTS_TEXTURE, texelcoord, 0).rgb;
		#else
			vec3 viewPos = screenToView(vec3(texcoord, 1.0)  ARGS_IN);
			skyColor = getSkyColor(normalize(viewPos)  ARGS_IN);
			skyColor += texelFetch(SKY_OBJECTS_TEXTURE, texelcoord, 0).rgb * (1.0 - 0.75 * skyColor);
		#endif
	}
	
	
	if (skyAmount == 1.0) {
		color = skyColor;
	} else {
		
		vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		vec2 lmcoord = unpackVec2(data.x) * 4.0;
		float specular_amount = unpackVec2(data.z).y;
		vec3 normal = decodeNormal(unpackVec2(data.y));
		doFshLighting(color, lmcoord.x, lmcoord.y, specular_amount, viewPos, normal  ARGS_IN);
		
		#if BORDER_FOG_ENABLED == 1
			color = mix(color, skyColor, skyAmount);
		#endif
		
		#if SSAO_ENABLED == 1
			if (!depthIsHand(depth)) {
				float aoFactor = getAoFactor(depth, length(viewPos)  ARGS_IN);
				aoFactor *= 1.0 - 0.7 * getLum(color);
				color *= 1.0 - aoFactor * AO_AMOUNT;
				//color = vec3(aoFactor);
			}
		#endif
		
	}
	
	
	/* DRAWBUFFERS:0 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

#include "/utils/getShadowcasterLight.glsl"

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0.xy;
	shadowcasterLight = getShadowcasterLight(ARG_IN);
}

#endif
