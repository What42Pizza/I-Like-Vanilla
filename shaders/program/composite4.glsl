in_out vec2 texcoord;



#ifdef FSH

#if DOF_ENABLED == 1
	#include "/lib/depth_of_field.glsl"
#endif
#if REFLECTIONS_ENABLED == 1
	#include "/utils/depth.glsl"
	#include "/utils/screen_to_view.glsl"
	#include "/utils/getSkyColor.glsl"
	#include "/lib/reflections.glsl"
#endif



#if REFLECTIONS_ENABLED == 1
	void doReflections(inout vec3 color, float depth, float dhDepth, vec3 normal, vec2 lmcoord, float reflectionStrength) {
		
		if (depthIsHand(depth)) return;
		#ifdef DISTANT_HORIZONS
			if (depth == 1.0 && dhDepth == 1.0) return;
		#else
			if (depth == 1.0) return;
		#endif
		
		vec3 screenPos = vec3(texcoord, depth);
		//screenPos.xy = floor(screenPos.xy * 256 * vec2(aspectRatio, 1)) / 256 * vec2(invAspectRatio, 1);
		vec3 viewPos = screenToView(screenPos);
		#ifdef DISTANT_HORIZONS
			if (depth == 1.0) viewPos = screenToViewDh(vec3(texcoord, dhDepth));
		#endif
		
		addReflection(color, viewPos, normal, lmcoord, MAIN_TEXTURE, reflectionStrength);
		
	}
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE, texelcoord, 0).rgb * 2.0;
	
	
	
	// ======== DEPTH OF FIELD ======== //
	
	#if DOF_ENABLED == 1
		doDOF(color);
	#endif
	
	
	
	// ======== REFLECTIONS ======== //
	
	#if REFLECTIONS_ENABLED == 1
		
		vec4 data;
		float depth0 = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float depth1 = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		bool useTransparentData = depth0 < depth1; // if transparents depth is less than non-transparents depth then use transparents data tex
		#ifdef DISTANT_HORIZONS
			float dhDepth0 = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
			float dhDepth1 = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
			useTransparentData = useTransparentData || dhDepth0 < dhDepth1;
		#endif
		#ifdef VOXY
			float vxDepth0 = texelFetch(VX_DEPTH_BUFFER_TRANS, texelcoord, 0).r;
			float vxDepth1 = texelFetch(VX_DEPTH_BUFFER_OPAQUE, texelcoord, 0).r;
			useTransparentData = useTransparentData || vxDepth0 < vxDepth1;
		#endif
		if (useTransparentData) {
			data = texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0);
		} else {
			data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		}
		vec3 normal = decodeNormal(data.zw);
		vec2 lmcoord = unpack_2x8(data.x);
		
		#if REFLECTIVE_EVERYTHING == 1
			float reflectionStrength = 1.0;
		#else
			float reflectionStrength = unpack_2x8(data.y).x;
		#endif
		#if REALISTIC_CLOUDS_ENABLED == 1 || NETHER_CLOUDS_ENABLED == 1 || END_CLOUDS_ENABLED == 1
			float invCloudsThickness = unpack_2x8(texelFetch(NOISY_RENDERS_TEXTURE, texelcoord, 0).g).x;
			reflectionStrength *= sqrt(invCloudsThickness);
		#endif
		if (reflectionStrength > 0.01) {
			#ifdef DISTANT_HORIZONS
				doReflections(color, depth0, dhDepth0, normal, lmcoord, reflectionStrength);
			#else
				doReflections(color, depth0, 0.0, normal, lmcoord, reflectionStrength);
			#endif
		}
		
	#endif
	
	
	
	/* DRAWBUFFERS:0 */
	color *= 0.5;
	gl_FragData[0] = vec4(color, 1.0);
	
}

#endif



#ifdef VSH

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
