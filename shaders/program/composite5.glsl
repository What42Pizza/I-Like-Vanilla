#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#include "/utils/reprojection.glsl"
#ifdef DISTANT_HORIZONS
	#include "/utils/screen_to_view.glsl"
#endif

#if SSS_PHOSPHOR == 1
	#include "/lib/super_secret_settings/phosphor.glsl"
#endif
#if FXAA_ENABLED == 1
	#include "/lib/fxaa.glsl"
#endif
#if TEMPORAL_FILTER_ENABLED == 1
	#include "/utils/depth.glsl"
	#include "/lib/temporal_filter.glsl"
#endif
#if MOTION_BLUR_ENABLED == 1
	#include "/lib/motion_blur.glsl"
#endif

void main() {
	
	// super secret settings
	ivec2 sampleCoord = texelcoord;
	#if SSS_PIXELS != 0
		#include "/import/viewSize.glsl"
		int texelSize = int(viewSize.y) / SSS_PIXELS;
		sampleCoord /= texelSize;
		sampleCoord *= texelSize;
	#endif
	
	vec3 color = texelFetch(MAIN_TEXTURE, sampleCoord, 0).rgb * 2.0;
	
	
	
	// super secret settings
	
	#if SSS_PHOSPHOR == 1
		sss_phosphor(color  ARGS_IN);
	#endif
	
	
	
	float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	#ifdef DISTANT_HORIZONS
		vec3 realBlockViewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		vec3 realBlockViewPosDh = screenToViewDh(vec3(texcoord, depthDh)  ARGS_IN);
		if (dot(realBlockViewPosDh, realBlockViewPosDh) < dot(realBlockViewPos, realBlockViewPos)) realBlockViewPos = realBlockViewPosDh;
		#include "/import/gbufferProjection.glsl"
		vec4 sampleScreenPos = gbufferProjection * vec4(realBlockViewPos, 1.0);
		depth = sampleScreenPos.z / sampleScreenPos.w * 0.5 + 0.5;
	#else
		float depthDh = 1.0;
	#endif
	
	vec3 pos = vec3(texcoord, depth);
	vec2 prevCoord = texcoord;
	if (!depthIsHand(depth)) {
		#include "/import/cameraPosition.glsl"
		#include "/import/previousCameraPosition.glsl"
		vec3 cameraOffset = cameraPosition - previousCameraPosition;
		prevCoord = reprojection(pos, cameraOffset  ARGS_IN);
	}
	
	
	
	// ======== FXAA ======== //
	#if FXAA_ENABLED == 1
		doFxaa(color, MAIN_TEXTURE  ARGS_IN);
	#endif
	
	// ======== TEMPORAL FILTER ======== //
	#if TEMPORAL_FILTER_ENABLED == 1
		doTemporalFilter(color, depth, depthDh, prevCoord  ARGS_IN);
	#endif
	
	
	
	// ======== MOTION BLUR ======== //
	
	#if MOTION_BLUR_ENABLED == 1
		vec3 prevColor = color;
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord, depth  ARGS_IN);
		}
	#endif
	
	
	
	/* DRAWBUFFERS:1 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	#if TEMPORAL_FILTER_ENABLED == 1 || SSS_PHOSPHOR == 1 || MOTION_BLUR_ENABLED == 1
		/* DRAWBUFFERS:14 */
		#if MOTION_BLUR_ENABLED == 1
			prevColor *= 0.5;
			gl_FragData[1] = vec4(prevColor, 1.0);
		#else
			gl_FragData[1] = vec4(color, 1.0);
		#endif
	#endif
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
