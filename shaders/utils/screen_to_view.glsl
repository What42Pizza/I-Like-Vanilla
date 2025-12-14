#ifndef INCLUDE_SCREEN_TO_VIEW
#define INCLUDE_SCREEN_TO_VIEW



#if ISOMETRIC_RENDERING_ENABLED == 0
	
	// CODE FROM COMPLEMENTARY REIMAGINED:
	vec3 screenToView(vec3 pos) {
		vec4 iProjDiag = vec4(
			gbufferProjectionInverse[0].x,
			gbufferProjectionInverse[1].y,
			gbufferProjectionInverse[2].zw
		);
		vec3 p3 = pos * 2.0 - 1.0;
		vec4 viewPos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
		return viewPos.xyz / viewPos.w;
	}
	// END OF COMPLEMENTARY REIMAGINED'S CODE
	
	#ifdef DISTANT_HORIZONS
		vec3 screenToViewDh(vec3 pos) {
			vec4 iProjDiag = vec4(
				dhProjectionInverse[0].x,
				dhProjectionInverse[1].y,
				dhProjectionInverse[2].zw
			);
			vec3 p3 = pos * 2.0 - 1.0;
			vec4 viewPos = iProjDiag * p3.xyzz + dhProjectionInverse[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
	#ifdef VOXY
		vec3 screenToViewVx(vec3 pos) {
			vec4 iProjDiag = vec4(
				vxProjInv[0].x,
				vxProjInv[1].y,
				vxProjInv[2].zw
			);
			vec3 p3 = pos * 2.0 - 1.0;
			vec4 viewPos = iProjDiag * p3.xyzz + vxProjInv[3];
			return viewPos.xyz / viewPos.w;
		}
	#endif
	
#else
	
	#include "/utils/isometric.glsl"
	
	vec3 screenToView(vec3 pos) {
		pos = pos * 2.0 - 1.0;
		pos.z += getIsometricOffset();
		pos /= getIsometricScale();
		return pos;
	}
	
	#ifdef DISTANT_HORIZONS
		vec3 screenToViewDh(vec3 pos) {
			pos = pos * 2.0 - 1.0;
			pos.z += getIsometricOffset();
			pos /= getIsometricScale();
			return pos;
		}
	#endif
	
#endif



#endif
