in_out vec2 texcoord;

#if SSS_LIDAR == 1
	const int lidarSampleCount = 24;
	in_out vec2 lidarSampleCoords[lidarSampleCount];
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
		int texelSize = int(viewSize.y) / SSS_PIXELS;
		sampleCoord /= texelSize;
		sampleCoord *= texelSize;
	#endif
	
	vec3 color = texelFetch(MAIN_TEXTURE, sampleCoord, 0).rgb * 2.0;
	
	
	
	// super secret settings
	
	#if SSS_PHOSPHOR == 1
		sss_phosphor(color);
	#endif
	
	
	
	float depth = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
	#ifdef DISTANT_HORIZONS
		vec3 viewPos = screenToView(vec3(texcoord, depth));
		float depthDh = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		vec3 viewPosDh = screenToViewDh(vec3(texcoord, depthDh));
		if (dot(viewPosDh, viewPosDh) < dot(viewPos, viewPos)) viewPos = viewPosDh;
		vec4 sampleScreenPos = gbufferProjection * vec4(viewPos, 1.0);
		depth = sampleScreenPos.z / sampleScreenPos.w * 0.5 + 0.5;
	#else
		float depthDh = 1.0;
	#endif
	
	vec3 pos = vec3(texcoord, depth);
	vec2 prevCoord = texcoord;
	bool doReprojection = !depthIsHand(depth);
	#if SSS_LIDAR == 1
		doReprojection = true;
	#endif
	if (doReprojection) {
		vec3 cameraOffset = cameraPosition - previousCameraPosition;
		prevCoord = reprojection(pos, cameraOffset);
	}
	
	
	
	// ======== FXAA ======== //
	#if FXAA_ENABLED == 1
		doFxaa(color, MAIN_TEXTURE);
	#endif
	
	// ======== TEMPORAL FILTER ======== //
	#if TEMPORAL_FILTER_ENABLED == 1
		doTemporalFilter(color, depth, depthDh, prevCoord);
	#endif
	
	
	
	// ======== SSS LIDAR ======== //
	
	#if SSS_LIDAR == 1
		color = vec3(0.0);
		for (int i = 0; i < lidarSampleCount; i++) {
			float sampleDist = length((texcoord - lidarSampleCoords[i]) * vec2(aspectRatio, 1.0));
			if (sampleDist < 0.005) {
				color = texture2D(MAIN_TEXTURE, lidarSampleCoords[i]).rgb * 2.0;
			}
		}
		float linearDepth = toLinearDepth(depth); 
		float prevLinearDepth = toLinearDepth(texture2D(PREV_DEPTH_TEXTURE, prevCoord).r);
		float depthDiff = (linearDepth - prevLinearDepth) * far;
		if (depthDiff < 1.0 && clamp(prevCoord, 0.0, 1.0) == prevCoord) {
			color = max(color, texelFetch(PREV_TEXTURE, ivec2(prevCoord * viewSize), 0).rgb * 2.0) - 1.0 / 255.0;
		}
	#endif
	
	
	
	// ======== MOTION BLUR ======== //
	
	#if MOTION_BLUR_ENABLED == 1
		vec3 prevColor = color;
		if (length(texcoord - prevCoord) > 0.00001) {
			doMotionBlur(color, prevCoord);
		}
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	#if TEMPORAL_FILTER_ENABLED == 1 || SSS_PHOSPHOR == 1 || MOTION_BLUR_ENABLED == 1
		/* DRAWBUFFERS:01 */
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
	
	#if SSS_LIDAR == 1
		uint rng = uint(frameCounter * lidarSampleCount);
		for (int i = 0; i < lidarSampleCount; i++) {
			lidarSampleCoords[i].x = randomFloat(rng) * 0.5 + 0.5;
			lidarSampleCoords[i].y = randomFloat(rng) * 0.5 + 0.5;
		}
	#endif
	
}

#endif
