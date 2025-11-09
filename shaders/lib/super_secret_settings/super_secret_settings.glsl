#if SSS_POSTERIZE == 1
	#include "/lib/super_secret_settings/posterize.glsl"
#endif
#if SSS_NOTCH == 1
	#include "/lib/super_secret_settings/notch.glsl"
#endif
#if SSS_BUMPY == 1
	#include "/lib/super_secret_settings/bumpy.glsl"
#endif
#if SSS_SCANLINES == 1
	#include "/lib/super_secret_settings/scanlines.glsl"
#endif



void doSuperSecretSettings(inout vec3 color) {
	
	#if SSS_POSTERIZE == 1
		sss_posterize(color);
	#endif
	#if SSS_NOTCH == 1
		sss_notch(color);
	#endif
	#if SSS_BUMPY == 1
		sss_bumpy(color);
	#endif
	#if SSS_SCANLINES == 1
		sss_scanlines(color);
	#endif
	
}
