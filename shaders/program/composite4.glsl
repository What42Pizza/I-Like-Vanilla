#ifdef FIRST_PASS
	in_out vec2 texcoord;
#endif



#ifdef FSH

#if DOF_ENABLED == 1
	#include "/lib/depth_of_field.glsl"
#endif
#if REFLECTIONS_ENABLED == 1
	#include "/utils/depth.glsl"
	#include "/utils/screen_to_view.glsl"
	#include "/utils/getSkyColor.glsl"
	#include "/lib/reflections.glsl"
	#if BORDER_FOG_ENABLED == 1
		#include "/lib/borderFog/getBorderFogAmount.glsl"
	#endif
#endif
#if REALISTIC_CLOUDS_ENABLED == 1
	#include "/lib/clouds.glsl"
#endif



#if REFLECTIONS_ENABLED == 1
	void doReflections(inout vec3 color, float depth, float dhDepth, vec3 normal, float reflectionStrength  ARGS_OUT) {
		
		if (depthIsHand(depth)) return;
		#ifdef DISTANT_HORIZONS
			if (depth == 1.0 && dhDepth == 1.0) return;
		#else
			if (depth == 1.0) return;
		#endif
		
		vec3 viewPos = screenToView(vec3(texcoord, depth)  ARGS_IN);
		#ifdef DISTANT_HORIZONS
			if (depth == 1.0) viewPos = screenToViewDh(vec3(texcoord, dhDepth)  ARGS_IN);
		#endif
		
		#if BORDER_FOG_ENABLED == 1
			#include "/import/gbufferModelViewInverse.glsl"
			vec3 playerPos = (gbufferModelViewInverse * startMat(viewPos)).xyz;
			float fogAmount = getBorderFogAmount(playerPos  ARGS_IN);
			if (fogAmount > 0.99) return;
			reflectionStrength *= 1.0 - fogAmount;
		#endif
		
		float initialDepth = depth;
		if (depth == 1.0) initialDepth = dhDepth;
		addReflection(color, viewPos, initialDepth, normal, MAIN_TEXTURE, reflectionStrength  ARGS_IN);
		
	}
#endif

void main() {
	vec3 color = texelFetch(MAIN_TEXTURE_COPY, texelcoord, 0).rgb * 2.0;
	
	
	
	// ======== DEPTH OF FIELD ======== //
	
	#if DOF_ENABLED == 1
		doDOF(color  ARGS_IN);
	#endif
	
	
	
	// ======== REFLECTIONS ======== //
	
	#if REFLECTIONS_ENABLED == 1
		
		vec4 data;
		float depth0 = texelFetch(DEPTH_BUFFER_ALL, texelcoord, 0).r;
		float depth1 = texelFetch(DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
		bool shouldUseTransparent = depth0 < depth1; // if transparents depth is less than non-transparents depth then use transparents data tex
		#ifdef DISTANT_HORIZONS
			float dhDepth0 = texelFetch(DH_DEPTH_BUFFER_ALL, texelcoord, 0).r;
			float dhDepth1 = texelFetch(DH_DEPTH_BUFFER_WO_TRANS, texelcoord, 0).r;
			shouldUseTransparent = shouldUseTransparent || dhDepth0 < dhDepth1;
		#endif
		if (shouldUseTransparent) {
			data = texelFetch(TRANSPARENT_DATA_TEXTURE, texelcoord, 0);
		} else {
			data = texelFetch(OPAQUE_DATA_TEXTURE, texelcoord, 0);
		}
		vec3 normal = decodeNormal(unpackVec2(data.y));
		
		#if REFLECTIVE_EVERYTHING == 1
			float reflectionStrength = 1.0;
		#else
			float reflectionStrength = unpackVec2(data.z).x;
		#endif
		if (reflectionStrength > 0.01) {
			#ifdef DISTANT_HORIZONS
				doReflections(color, depth0, dhDepth0, normal, reflectionStrength  ARGS_IN);
			#else
				doReflections(color, depth0, 0.0, normal, reflectionStrength  ARGS_IN);
			#endif
		}
		
	#endif
	
	
	
	#if REALISTIC_CLOUDS_ENABLED == 1 && defined OVERWORLD
		renderClouds(color  ARGS_IN);
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
