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
#ifdef DISTANT_HORIZONS
	#define LOD_SCREEN_TO_VIEW_FN screenToViewDh
	#define LOD_DEPTH_TEX DH_DEPTH_BUFFER_ALL
	#define LOD_MODEL_VIEW_INVERSE_MAT gbufferModelViewInverse
	#define LOD_PROJECTION_MAT dhProjection
	#include "/lib/lod_ssao.glsl"
#endif
#ifdef VOXY
	#define LOD_SCREEN_TO_VIEW_FN screenToViewVx
	#define LOD_DEPTH_TEX vxDepthTexOpaque
	#define LOD_MODEL_VIEW_INVERSE_MAT vxModelViewInv
	#define LOD_PROJECTION_MAT vxProj
	#include "/lib/lod_ssao.glsl"
#endif
#if BORDER_FOG_ENABLED == 1
	#include "/utils/borderFogAmount.glsl"
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
	
	vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
	#ifdef DISTANT_HORIZONS
		float skyAmount = uint(depth == 1.0 && dhDepth == 1.0);
		float fogDistance = skyAmount;
	#else
		#if BORDER_FOG_ENABLED == 1
			float fogDistance;
			float skyAmount = getBorderFogAmount(playerPos, fogDistance);
			#if FOG_BUG_RECREATION == 1
				skyAmount *= 1.0 - 0.0001 * uint(depth < 1.0);
			#endif
		#else
			float skyAmount = uint(depth == 1.0);
			float fogDistance = skyAmount;
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
			
			#if CYLINDRICAL_CLIPPING == 1
				const float objectsMixingSlope = 16.0;
			#else
				const float objectsMixingSlope = 32.0;
			#endif
			vec3 skyObjects = texelFetch(SKY_OBJECTS_TEXTURE, texelcoord, 0).rgb * (1.0 - 0.6 * skyColor) * clamp(1.0 - objectsMixingSlope * (1.0 - fogDistance), 0.0, 1.0);
			#if defined OVERWORLD && CUSTOM_OVERWORLD_SKYBOX == 1
				skyObjects *= OVERWORLD_SKYBOX_BRIGHTNESS;
			#endif
			#if defined NETHER && CUSTOM_NETHER_SKYBOX == 1
				skyObjects *= NETHER_SKYBOX_BRIGHTNESS;
			#endif
			#if defined END && CUSTOM_END_SKYBOX == 1
				skyObjects *= END_SKYBOX_BRIGHTNESS;
			#endif
			skyColor += skyObjects;
		#endif
	}
	
	
	if (skyAmount == 1.0) {
		color = skyColor;
	} else {
		
		vec4 data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		vec2 lmcoord = unpack_2x8(data.x);
		vec2 refPlusSpec = unpack_2x8(data.y);
		float reflectiveness = refPlusSpec.x;
		float specularness = refPlusSpec.y;
		vec3 normal = decodeNormal(data.zw);
		#ifndef MODERN_BACKEND
			vec3 viewPosUp    = screenToView(vec3(texcoord + ivec2( 0, -1) * pixelSize, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2( 0, -1), 0).r));
			vec3 viewPosDown  = screenToView(vec3(texcoord + ivec2( 0,  1) * pixelSize, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2( 0,  1), 0).r));
			vec3 viewPosLeft  = screenToView(vec3(texcoord + ivec2(-1,  0) * pixelSize, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2(-1,  0), 0).r));
			vec3 viewPosRight = screenToView(vec3(texcoord + ivec2( 1,  0) * pixelSize, texelFetch(DEPTH_BUFFER_ALL, texelcoord + ivec2( 1,  0), 0).r));
			vec3 xDir = normalize(viewPosLeft - viewPosRight);
			vec3 yDir = normalize(viewPosUp - viewPosDown);
			normal = cross(xDir, yDir);
		#endif
		float glowingAmount = 0.0;
		if (abs(specularness - 254.0 / 255.0) < 0.001) {
			glowingAmount = reflectiveness * 2.0;
			reflectiveness = 0.0;
			specularness = 0.0;
		}
		float shadowBrightness;
		doFshLighting(color, shadowBrightness, lmcoord.x, lmcoord.y, specularness, glowingAmount, viewPos, normal, depth);
		
		#if SSAO_ENABLED == 1
			if (!depthIsHand(depth)) {
				float aoFactor = getAoAmount(depth);
				aoFactor *= 1.0 - 0.5 * getLum(color);
				aoFactor *= 1.0 - 0.4 * nightVision;
				color *= 1.0 - aoFactor * mix(AO_AMOUNT_UNLIT, AO_AMOUNT_LIT, max(shadowBrightness, lmcoord.x));
				//color = vec3(aoFactor);
			}
		#endif
		
		#ifdef DISTANT_HORIZONS
			
			if (depth == 1.0 && dhDepth != 1.0) {
				float vxAo = getLodAoAmount(normal);
				color *= 0.98 - vxAo * 0.49 * VANILLA_AO_BRIGHT;
			}
			
		#endif
		
		#ifdef VOXY
			
			float voxyOpaqueDepth = texelFetch(VX_DEPTH_BUFFER_OPAQUE, texelcoord, 0).r;
			vec3 voxyOpaqueViewPos = screenToViewVx(vec3(texcoord, voxyOpaqueDepth));
			if (voxyOpaqueViewPos.z > viewPos.z - 0.5) {
				float vxAo = getLodAoAmount(normal);
				color *= 0.98 - vxAo * 0.49 * VANILLA_AO_BRIGHT;
			}
			
			float voxyTransparentDepth = texelFetch(VX_DEPTH_BUFFER_TRANS, texelcoord, 0).r;
			vec3 voxyTransparentViewPos = screenToViewVx(vec3(texcoord, voxyTransparentDepth));
			if (voxyTransparentViewPos.z > voxyOpaqueViewPos.z - 0.5 && depth > 0.998) {
				vec4 voxyTransparents = texelFetch(VOXY_TRANSPARENTS_TEXTURE, texelcoord, 0);
				voxyTransparents.rgb *= 2.0;
				voxyTransparents.a *= uint(!depthIsHand(depth));
				color.rgb = mix(color.rgb, voxyTransparents.rgb, voxyTransparents.a);
			}
			
		#endif
		
		#if BORDER_FOG_ENABLED == 1
			#if FOG_BUG_RECREATION == 1
				skyColor += FOG_BUG_AMOUNT * 0.1;
			#endif
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
