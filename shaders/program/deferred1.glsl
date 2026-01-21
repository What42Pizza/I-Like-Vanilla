in_out vec2 texcoord;
flat in_out vec3 shadowcasterLight;



#ifdef FSH



#include "/lib/lighting/fsh_lighting.glsl"
#include "/utils/depth.glsl"
#include "/utils/screen_to_view.glsl"
#include "/utils/getSkyColor.glsl"

#if OUTLINES_ENABLED == 1
	#include "/lib/outlines.glsl"
#endif
#if SSAO_ENABLED == 1
	#include "/lib/ssao.glsl"
#endif
#ifdef VOXY
	#include "/lib/voxy_ssao.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/lib/borderFogAmount.glsl"
#endif



void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	float depth = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
	vec3 viewPos = screenToView(vec3(texcoord, depth + 0.38 * uint(depthIsHand(depth))));
	#ifdef DISTANT_HORIZONS
		float dhDepth = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
		vec3 dhViewPos = screenToViewDh(vec3(texcoord, dhDepth));
		if (dhViewPos.z > viewPos.z) viewPos = dhViewPos;
	#endif
	
	vec3 playerPos = transform(gbufferModelViewInverse, viewPos);
	#ifdef DISTANT_HORIZONS
		float skyAmount = uint(depth == 1.0 && dhDepth == 1.0);
	#else
		#if BORDER_FOG_ENABLED == 1
			float skyAmount = getBorderFogAmount(playerPos);
		#else
			float skyAmount = uint(depth == 1.0);
		#endif
	#endif
	
	
	#if OUTLINES_ENABLED == 1
		color *= 1.0 - getOutlineAmount();
	#endif
	
	
	vec3 skyColor = vec3(0.0);
	if (skyAmount > 0.0) {
		vec3 viewPos = screenToView(vec3(texcoord, 1.0));
		skyColor = getSkyColor(normalize(viewPos), true);
		#if defined OVERWORLD || defined CUSTOM_SKYBOX
			vec3 skyObjects = texelFetch(SKY_OBJECTS_TEXTURE, texelcoord, 0).rgb * (1.0 - 0.6 * skyColor) * max(1.0 - 6.0 * (1.0 - skyAmount), 0.0);
			#ifdef CUSTOM_SKYBOX
				skyObjects *= 1.25;
			#endif
			skyColor += skyObjects;
		#endif
	}
	
	
	if (skyAmount == 1.0) {
		color = skyColor;
	} else {
		
		vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		vec2 lmcoord = unpack_2x8(data.x);
		float specularness = unpack_2x8(data.y).y;
		vec3 normal = decodeNormal(data.zw);
		doFshLighting(color, lmcoord.x, lmcoord.y, specularness, viewPos, normal, depth);
		
		#if SSAO_ENABLED == 1
			if (!depthIsHand(depth)) {
				float aoFactor = getAoAmount(depth);
				aoFactor *= 1.0 - 0.5 * getLum(color);
				aoFactor *= 1.0 - 0.4 * nightVision;
				color *= 1.0 - aoFactor * AO_AMOUNT;
				//color = vec3(aoFactor);
			}
		#endif
		
		#ifdef VOXY
			
			float voxyOpaqueDepth = texelFetch(VX_DEPTH_BUFFER_OPAQUE, texelcoord, 0).r;
			vec3 voxyOpaqueViewPos = screenToViewVx(vec3(texcoord, voxyOpaqueDepth));
			if (voxyOpaqueViewPos.z > viewPos.z - 0.5) {
				float vxAo = getVoxyAoAmount(normal);
				color *= 1.03 - vxAo * 0.45;
			}
			
			float voxyTransparentDepth = texelFetch(VX_DEPTH_BUFFER_TRANS, texelcoord, 0).r;
			vec3 voxyTransparentViewPos = screenToViewVx(vec3(texcoord, voxyTransparentDepth));
			if (voxyTransparentViewPos.z > voxyOpaqueViewPos.z - 0.5 && depth > 0.999) {
				vec4 voxyTransparents = texelFetch(VOXY_TRANSPARENTS_TEXTURE, texelcoord, 0);
				voxyTransparents.rgb *= 2.0;
				voxyTransparents.a *= uint(!depthIsHand(depth));
				color.rgb = mix(color.rgb, voxyTransparents.rgb, voxyTransparents.a);
			}
			
		#endif
		
		#if BORDER_FOG_ENABLED == 1
			color = mix(color, skyColor, skyAmount);
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
	shadowcasterLight = getShadowcasterLight();
}

#endif
